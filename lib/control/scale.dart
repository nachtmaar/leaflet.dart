

// Scale is used for displaying metric/imperial scale on the map.
class Scale extends Control {
  var options = {
    'position': 'bottomleft',
    'maxWidth': 100,
    'metric': true,
    'imperial': true,
    'updateWhenIdle': false
  };

  onAdd(map) {
    this._map = map;

    var className = 'leaflet-control-scale',
        container = L.DomUtil.create('div', className),
        options = this.options;

    this._addScales(options, className, container);

    map.on(options.updateWhenIdle ? 'moveend' : 'move', this._update, this);
    map.whenReady(this._update, this);

    return container;
  }

  onRemove(map) {
    map.off(this.options.updateWhenIdle ? 'moveend' : 'move', this._update, this);
  }

  _addScales(options, className, container) {
    if (options.metric) {
      this._mScale = L.DomUtil.create('div', className + '-line', container);
    }
    if (options.imperial) {
      this._iScale = L.DomUtil.create('div', className + '-line', container);
    }
  }

  _update() {
    var bounds = this._map.getBounds(),
        centerLat = bounds.getCenter().lat,
        halfWorldMeters = 6378137 * Math.PI * Math.cos(centerLat * Math.PI / 180),
        dist = halfWorldMeters * (bounds.getNorthEast().lng - bounds.getSouthWest().lng) / 180,

        size = this._map.getSize(),
        options = this.options,
        maxMeters = 0;

    if (size.x > 0) {
      maxMeters = dist * (options.maxWidth / size.x);
    }

    this._updateScales(options, maxMeters);
  }

  _updateScales(options, maxMeters) {
    if (options.metric && maxMeters) {
      this._updateMetric(maxMeters);
    }

    if (options.imperial && maxMeters) {
      this._updateImperial(maxMeters);
    }
  }

  _updateMetric(maxMeters) {
    var meters = this._getRoundNum(maxMeters);

    this._mScale.style.width = this._getScaleWidth(meters / maxMeters) + 'px';
    this._mScale.innerHTML = meters < 1000 ? meters + ' m' : (meters / 1000) + ' km';
  }

  _updateImperial(maxMeters) {
    var maxFeet = maxMeters * 3.2808399,
        scale = this._iScale,
        maxMiles, miles, feet;

    if (maxFeet > 5280) {
      maxMiles = maxFeet / 5280;
      miles = this._getRoundNum(maxMiles);

      scale.style.width = this._getScaleWidth(miles / maxMiles) + 'px';
      scale.innerHTML = miles + ' mi';

    } else {
      feet = this._getRoundNum(maxFeet);

      scale.style.width = this._getScaleWidth(feet / maxFeet) + 'px';
      scale.innerHTML = feet + ' ft';
    }
  }

  _getScaleWidth(ratio) {
    return Math.round(this.options.maxWidth * ratio) - 10;
  }

  _getRoundNum(num) {
    var pow10 = Math.pow(10, (Math.floor(num) + '').length - 1),
        d = num / pow10;

    d = d >= 10 ? 10 : d >= 5 ? 5 : d >= 3 ? 3 : d >= 2 ? 2 : 1;

    return pow10 * d;
  }
}