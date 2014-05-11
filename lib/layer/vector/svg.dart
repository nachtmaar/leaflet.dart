
var SVG_NS = 'http://www.w3.org/2000/svg';

// Extends Path with SVG-specific rendering code.
class Path {
  static var SVG = L.Browser.svg;

  bringToFront() {
    var root = this._map._pathRoot,
        path = this._container;

    if (path && root.lastChild != path) {
      root.appendChild(path);
    }
    return this;
  }

  bringToBack() {
    var root = this._map._pathRoot,
        path = this._container,
        first = root.firstChild;

    if (path && first != path) {
      root.insertBefore(path, first);
    }
    return this;
  }

  getPathString() {
    // form path string here
  }

  _createElement(name) {
    return document.createElementNS(L.Path.SVG_NS, name);
  }

  _initElements() {
    this._map._initPathRoot();
    this._initPath();
    this._initStyle();
  }

  _initPath() {
    this._container = this._createElement('g');

    this._path = this._createElement('path');

    if (this.options.className) {
      L.DomUtil.addClass(this._path, this.options.className);
    }

    this._container.appendChild(this._path);
  }

  _initStyle() {
    if (this.options.stroke) {
      this._path.setAttribute('stroke-linejoin', 'round');
      this._path.setAttribute('stroke-linecap', 'round');
    }
    if (this.options.fill) {
      this._path.setAttribute('fill-rule', 'evenodd');
    }
    if (this.options.pointerEvents) {
      this._path.setAttribute('pointer-events', this.options.pointerEvents);
    }
    if (!this.options.clickable && !this.options.pointerEvents) {
      this._path.setAttribute('pointer-events', 'none');
    }
    this._updateStyle();
  }

  _updateStyle() {
    if (this.options.stroke) {
      this._path.setAttribute('stroke', this.options.color);
      this._path.setAttribute('stroke-opacity', this.options.opacity);
      this._path.setAttribute('stroke-width', this.options.weight);
      if (this.options.dashArray) {
        this._path.setAttribute('stroke-dasharray', this.options.dashArray);
      } else {
        this._path.removeAttribute('stroke-dasharray');
      }
      if (this.options.lineCap) {
        this._path.setAttribute('stroke-linecap', this.options.lineCap);
      }
      if (this.options.lineJoin) {
        this._path.setAttribute('stroke-linejoin', this.options.lineJoin);
      }
    } else {
      this._path.setAttribute('stroke', 'none');
    }
    if (this.options.fill) {
      this._path.setAttribute('fill', this.options.fillColor || this.options.color);
      this._path.setAttribute('fill-opacity', this.options.fillOpacity);
    } else {
      this._path.setAttribute('fill', 'none');
    }
  }

  _updatePath() {
    var str = this.getPathString();
    if (!str) {
      // fix webkit empty string parsing bug
      str = 'M0 0';
    }
    this._path.setAttribute('d', str);
  }

  // TODO remove duplication with L.Map
  _initEvents() {
    if (this.options.clickable) {
      if (L.Browser.svg || !L.Browser.vml) {
        L.DomUtil.addClass(this._path, 'leaflet-clickable');
      }

      L.DomEvent.on(this._container, 'click', this._onMouseClick, this);

      var events = ['dblclick', 'mousedown', 'mouseover',
                    'mouseout', 'mousemove', 'contextmenu'];
      for (var i = 0; i < events.length; i++) {
        L.DomEvent.on(this._container, events[i], this._fireMouseEvent, this);
      }
    }
  }

  _onMouseClick(e) {
    if (this._map.dragging && this._map.dragging.moved()) { return; }

    this._fireMouseEvent(e);
  }

  _fireMouseEvent(e) {
    if (!this.hasEventListeners(e.type)) { return; }

    var map = this._map,
        containerPoint = map.mouseEventToContainerPoint(e),
        layerPoint = map.containerPointToLayerPoint(containerPoint),
        latlng = map.layerPointToLatLng(layerPoint);

    this.fire(e.type, {
      latlng: latlng,
      layerPoint: layerPoint,
      containerPoint: containerPoint,
      originalEvent: e
    });

    if (e.type == 'contextmenu') {
      L.DomEvent.preventDefault(e);
    }
    if (e.type != 'mousemove') {
      L.DomEvent.stopPropagation(e);
    }
  }
}

class Map {
  _initPathRoot() {
    if (!this._pathRoot) {
      this._pathRoot = L.Path.prototype._createElement('svg');
      this._panes.overlayPane.appendChild(this._pathRoot);

      if (this.options.zoomAnimation && L.Browser.any3d) {
        L.DomUtil.addClass(this._pathRoot, 'leaflet-zoom-animated');

        this.on({
          'zoomanim': this._animatePathZoom,
          'zoomend': this._endPathZoom
        });
      } else {
        L.DomUtil.addClass(this._pathRoot, 'leaflet-zoom-hide');
      }

      this.on('moveend', this._updateSvgViewport);
      this._updateSvgViewport();
    }
  }

  _animatePathZoom(e) {
    var scale = this.getZoomScale(e.zoom),
        offset = this._getCenterOffset(e.center)._multiplyBy(-scale)._add(this._pathViewport.min);

    this._pathRoot.style[L.DomUtil.TRANSFORM] =
            L.DomUtil.getTranslateString(offset) + ' scale(' + scale + ') ';

    this._pathZooming = true;
  }

  _endPathZoom() {
    this._pathZooming = false;
  }

  _updateSvgViewport() {

    if (this._pathZooming) {
      // Do not update SVGs while a zoom animation is going on otherwise the animation will break.
      // When the zoom animation ends we will be updated again anyway
      // This fixes the case where you do a momentum move and zoom while the move is still ongoing.
      return;
    }

    this._updatePathViewport();

    var vp = this._pathViewport,
        min = vp.min,
        max = vp.max,
        width = max.x - min.x,
        height = max.y - min.y,
        root = this._pathRoot,
        pane = this._panes.overlayPane;

    // Hack to make flicker on drag end on mobile webkit less irritating
    if (L.Browser.mobileWebkit) {
      pane.removeChild(root);
    }

    L.DomUtil.setPosition(root, min);
    root.setAttribute('width', width);
    root.setAttribute('height', height);
    root.setAttribute('viewBox', [min.x, min.y, width, height].join(' '));

    if (L.Browser.mobileWebkit) {
      pane.appendChild(root);
    }
  }
}