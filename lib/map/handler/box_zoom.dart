library map;

import 'dart:html';
import 'dart:math' as math;

import '../../core/handler.dart';

// BoxZoom is used to add shift-drag zoom interaction to the map
// (zoom to a selected bounding box), enabled by default.
class BoxZoom extends Handler {
  BoxZoom(map) {
    this._map = map;
    this._container = map._container;
    this._pane = map._panes.overlayPane;
    this._moved = false;
  }

  addHooks() {
    L.DomEvent.on(this._container, 'mousedown', this._onMouseDown, this);
  }

  removeHooks() {
    L.DomEvent.off(this._container, 'mousedown', this._onMouseDown);
    this._moved = false;
  }

  moved() {
    return this._moved;
  }

  _onMouseDown(e) {
    this._moved = false;

    if (!e.shiftKey || ((e.which != 1) && (e.button != 1))) { return false; }

    L.DomUtil.disableTextSelection();
    L.DomUtil.disableImageDrag();

    this._startLayerPoint = this._map.mouseEventToLayerPoint(e);

    L.DomEvent
        .on(document, 'mousemove', this._onMouseMove, this)
        .on(document, 'mouseup', this._onMouseUp, this)
        .on(document, 'keydown', this._onKeyDown, this);
  }

  _onMouseMove(e) {
    if (!this._moved) {
      this._box = L.DomUtil.create('div', 'leaflet-zoom-box', this._pane);
      L.DomUtil.setPosition(this._box, this._startLayerPoint);

      //TODO refactor: move cursor to styles
      this._container.style.cursor = 'crosshair';
      this._map.fire('boxzoomstart');
    }

    var startPoint = this._startLayerPoint,
        box = this._box,

        layerPoint = this._map.mouseEventToLayerPoint(e),
        offset = layerPoint.subtract(startPoint),

        newPos = new L.Point(
            Math.min(layerPoint.x, startPoint.x),
            Math.min(layerPoint.y, startPoint.y));

    L.DomUtil.setPosition(box, newPos);

    this._moved = true;

    // TODO refactor: remove hardcoded 4 pixels
    box.style.width  = (Math.max(0, Math.abs(offset.x) - 4)) + 'px';
    box.style.height = (Math.max(0, Math.abs(offset.y) - 4)) + 'px';
  }

  _finish() {
    if (this._moved) {
      this._pane.removeChild(this._box);
      this._container.style.cursor = '';
    }

    L.DomUtil.enableTextSelection();
    L.DomUtil.enableImageDrag();

    L.DomEvent
        .off(document, 'mousemove', this._onMouseMove)
        .off(document, 'mouseup', this._onMouseUp)
        .off(document, 'keydown', this._onKeyDown);
  }

  _onMouseUp(e) {

    this._finish();

    var map = this._map,
        layerPoint = map.mouseEventToLayerPoint(e);

    if (this._startLayerPoint.equals(layerPoint)) { return; }

    var bounds = new L.LatLngBounds(
            map.layerPointToLatLng(this._startLayerPoint),
            map.layerPointToLatLng(layerPoint));

    map.fitBounds(bounds);

    map.fire('boxzoomend', {
      boxZoomBounds: bounds
    });
  }

  _onKeyDown(e) {
    if (e.keyCode == 27) {
      this._finish();
    }
  }
}