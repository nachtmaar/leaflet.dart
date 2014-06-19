// Projection contains various geographical projections used by CRS classes.
library leaflet.geo.projection;

import 'dart:math' as math;

import '../geo.dart';
import '../../geometry/geometry.dart' as geom;

part 'lon_lat.dart';
part 'mercator.dart';
part 'spherical_mercator.dart';

/**
 * An object with methods for projecting geographical coordinates of the world
 * onto a flat surface (and back).
 */
abstract class Projection {
  /**
   * Projects geographical coordinates into a 2D point.
   */
  geom.Point project(LatLng latlng);

  /**
   * The inverse of project. Projects a 2D point into geographical location.
   */
  LatLng unproject(geom.Point point);
}