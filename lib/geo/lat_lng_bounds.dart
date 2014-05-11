part of leaflet.geo;

// LatLngBounds represents a rectangular area on the map in geographical coordinates.
class LatLngBounds {

  LatLng _southWest, _northEast;

  factory LatLngBounds.latLngBounds(LatLngBounds llb) {
    return llb;
  }

  LatLngBounds(southWest, northEast) { // (LatLng, LatLng) or (LatLng[])
    if (!southWest) { return; }

    var latlngs = northEast ? [southWest, northEast] : southWest;

    for (var i = 0, len = latlngs.length; i < len; i++) {
      this.extend(latlngs[i]);
    }
  }

  // Extend the bounds to contain the given point.
  LatLngBounds extend(LatLng obj) { // (LatLng) or (LatLngBounds)
    if (obj == null) { return this; }

    var latLng = new LatLng.latLng(obj);

    if (this._southWest ==null && this._northEast == null) {
      this._southWest = new LatLng(obj.lat, obj.lng);
      this._northEast = new LatLng(obj.lat, obj.lng);
    } else {
      this._southWest.lat = math.min(obj.lat, this._southWest.lat);
      this._southWest.lng = math.min(obj.lng, this._southWest.lng);

      this._northEast.lat = math.max(obj.lat, this._northEast.lat);
      this._northEast.lng = math.max(obj.lng, this._northEast.lng);
    }

    return this;
  }

  // Extend the bounds to contain the given bounds.
  LatLngBounds extendBounds(LatLngBounds obj) {
    if (obj == null) { return this; }

    obj = new LatLngBounds.latLngBounds(obj);

    this.extend(obj._southWest);
    this.extend(obj._northEast);

    return this;
  }

  // Extend the bounds by a percentage.
  LatLngBounds pad(num bufferRatio) { // (Number) -> LatLngBounds
    final sw = this._southWest;
    final ne = this._northEast;
    final heightBuffer = (sw.lat - ne.lat).abs() * bufferRatio;
    final widthBuffer = (sw.lng - ne.lng).abs() * bufferRatio;

    return new LatLngBounds(
            new LatLng(sw.lat - heightBuffer, sw.lng - widthBuffer),
            new LatLng(ne.lat + heightBuffer, ne.lng + widthBuffer));
  }

  LatLng getCenter() { // -> LatLng
    return new LatLng(
            (this._southWest.lat + this._northEast.lat) / 2,
            (this._southWest.lng + this._northEast.lng) / 2);
  }

  LatLng getSouthWest() {
    return this._southWest;
  }

  LatLng getNorthEast() {
    return this._northEast;
  }

  LatLng getNorthWest() {
    return new LatLng(this.getNorth(), this.getWest());
  }

  LatLng getSouthEast() {
    return new LatLng(this.getSouth(), this.getEast());
  }

  num getWest() {
    return this._southWest.lng;
  }

  num getSouth() {
    return this._southWest.lat;
  }

  num getEast() {
    return this._northEast.lng;
  }

  num getNorth() {
    return this._northEast.lat;
  }

  bool contains(LatLng obj) {
    obj = new LatLng.latLng(obj);

    final sw = this._southWest,
        ne = this._northEast;

    final sw2 = obj;
    final ne2 = obj;

    return (sw2.lat >= sw.lat) && (ne2.lat <= ne.lat) &&
           (sw2.lng >= sw.lng) && (ne2.lng <= ne.lng);
  }

  bool containsBounds(LatLngBounds obj) {
    obj = new LatLngBounds.latLngBounds(obj);

    final sw = this._southWest,
        ne = this._northEast;

    final sw2 = obj.getSouthWest();
    final ne2 = obj.getNorthEast();

    return (sw2.lat >= sw.lat) && (ne2.lat <= ne.lat) &&
           (sw2.lng >= sw.lng) && (ne2.lng <= ne.lng);
  }

  bool intersects(LatLngBounds bounds) {
    bounds = new LatLngBounds.latLngBounds(bounds);

    final sw = this._southWest,
        ne = this._northEast,
        sw2 = bounds.getSouthWest(),
        ne2 = bounds.getNorthEast(),

        latIntersects = (ne2.lat >= sw.lat) && (sw2.lat <= ne.lat),
        lngIntersects = (ne2.lng >= sw.lng) && (sw2.lng <= ne.lng);

    return latIntersects && lngIntersects;
  }

  String toBBoxString() {
    return [this.getWest(), this.getSouth(), this.getEast(), this.getNorth()].join(',');
  }

  bool equals(LatLngBounds bounds) {
    if (bounds == null) { return false; }

    bounds = new LatLngBounds.latLngBounds(bounds);

    return this._southWest.equals(bounds.getSouthWest()) &&
           this._northEast.equals(bounds.getNorthEast());
  }

  bool isValid() {
    return this._southWest != null && this._northEast != null;
  }
}