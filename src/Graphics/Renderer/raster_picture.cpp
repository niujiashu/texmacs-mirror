
/******************************************************************************
* MODULE     : raster_picture.cpp
* DESCRIPTION: Raster pictures
* COPYRIGHT  : (C) 2013  Joris van der Hoeven
*******************************************************************************
* This software falls under the GNU general public license version 3 or later.
* It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
* in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
******************************************************************************/

#include "alpha_color.hpp"
#include "raster_picture.hpp"

picture
raster_picture (int w, int h, int ox, int oy) {
  return raster_picture (raster<true_color> (w, h, ox, oy));
}

picture
as_raster_picture (picture pic) {
  if (pic->get_type () == picture_raster) return pic;
  picture ret= raster_picture (pic->get_width (), pic->get_height (),
                               pic->get_origin_x (), pic->get_origin_y ());
  pic->copy_to (ret);
  return ret;
}

true_color*
get_raster (picture pic) {
  return as_raster<true_color> (pic) -> a;
}

picture
copy_raster_picture (picture pic) {
  if (pic->get_type () != picture_raster) return as_raster_picture (pic);
  int w= pic->get_width (), h= pic->get_height ();
  int ox= pic->get_origin_x (), oy= pic->get_origin_y ();
  picture ret= raster_picture (w, h, ox, oy);
  true_color* d= get_raster (ret);
  true_color* s= get_raster (pic);
  for (int i=0; i<w*h; i++) d[i]= s[i];
  return ret;
}

picture
blur (picture pic, double r) {
  if (r <= 0.001) return pic;
  int R= max (3, ((int) (3.0 * r)));
  raster<true_color> ras= as_raster<true_color> (pic);
  return raster_picture (blur (ras, R, r));
}

picture
gravitational_outline (picture pic, int R, double expon) {
  raster<true_color> ras= as_raster<true_color> (pic);
  return raster_picture (gravitational_outline (ras, R, expon));
}

template<composition_mode M> picture
compose (picture pic, color c) {
  picture ret= copy_raster_picture (pic);
  int w= pic->get_width (), h= pic->get_height ();
  compose<M,true_color,true_color> (get_raster (ret), true_color (c), w, h, w);
  return ret;
}

picture
compose (picture orig, color c, composition_mode mode) {
  switch (mode) {
  case compose_destination:
    return compose<compose_destination> (orig, c);
  case compose_source:
    return compose<compose_source> (orig, c);
  case compose_source_over:
    return compose<compose_source_over> (orig, c);
  case compose_towards_source:
    return compose<compose_towards_source> (orig, c);
  default:
    return orig;
  }
}

template<composition_mode M> void
compose (picture& dest, picture src, int x, int y) {
  dest= as_raster_picture (dest);
  src = as_raster_picture (src );
  int dw= dest->get_width (), dh= dest->get_height ();
  int sw= src ->get_width (), sh= src ->get_height ();
  true_color* d= get_raster (dest);
  true_color* s= get_raster (src );
  int sw2= sw;
  int sh2= sh;
  if (x < 0) { s -= x; sw2 += x; x= 0; }
  if (y < 0) { s -= y * sw; sh2 += y; y= 0; }
  int w = min (sw2, dw - x);
  int h = min (sh2, dh - y);
  if (w <= 0 || h <= 0) return;
  d += y * dw + x;
  compose<M,true_color,true_color> (d, s, w, h, dw, sw);
}

void
compose (picture& dest, picture src, int x, int y, composition_mode mode) {
  switch (mode) {
  case compose_destination:
    compose<compose_destination> (dest, src, x, y);
    break;
  case compose_source:
    compose<compose_source> (dest, src, x, y);
    break;
  case compose_source_over:
    compose<compose_source_over> (dest, src, x, y);
    break;
  case compose_towards_source:
    compose<compose_towards_source> (dest, src, x, y);
    break;
  }
}

picture
combine (picture p1, picture p2, composition_mode mode) {
  int w1 = p1->get_width ()   , h1 = p1->get_height ();
  int ox1= p1->get_origin_x (), oy1= p1->get_origin_y ();
  int w2 = p2->get_width ()   , h2 = p2->get_height ();
  int ox2= p2->get_origin_x (), oy2= p2->get_origin_y ();
  int x1 = min (-ox1, -ox2);
  int y1 = min (-oy1, -oy2);
  int x2 = max (w1-ox1, w2-ox2);
  int y2 = max (h1-oy1, h2-oy2);
  int w  = x2 - x1;
  int h  = y2 - y1;
  picture ret= raster_picture (w, h, -x1, -y1);
  raster<true_color> ras= as_raster<true_color> (ret);
  clear (ras);
  compose (ret, p1, -ox1-x1, -oy1-y1, compose_source);
  compose (ret, p2, -ox2-x1, -oy2-y1, mode);
  return ret;
}

picture
add_shadow (picture pic, int x, int y, color c, double r) {
  picture shad= blur (compose (pic, c, compose_towards_source), r);
  shad->translate_origin (-x, -y);
  return combine (shad, pic, compose_source_over);
}

picture
engrave (picture pic, double a0, color tlc, color brc, double tlw, double brw) {
  pic= as_raster_picture (pic);
  int w= pic->get_width (), h= pic->get_height ();
  int ox= pic->get_origin_x (), oy= pic->get_origin_y ();
  raster<true_color> ras= as_raster<true_color> (pic);
  raster<double> tl= tl_distances (ras);
  raster<double> br= br_distances (ras);
  raster<true_color> ret (w, h, ox, oy);
  true_color c1 (tlc);
  true_color c2 (brc);
  for (int y=0; y<h; y++)
    for (int x=0; x<w; x++) {
      double d1= tl->a[y*w+x];
      double d2= br->a[y*w+x];
      double a1= 1.0 / (1.0 + d1*d1/(tlw*tlw));
      double a2= 1.0 / (1.0 + d2*d2/(brw*brw));
      true_color c0= ras->a[y*w+x];
      true_color cc (c0.r, c0.g, c0.b, a0);
      true_color mc= (a0 * cc + a1 * c1 + a2 * c2) / (a0 + a1 + a2);
      ret->a[y*w+x]= true_color (mc.r, mc.g, mc.b, c0.a * mc.a);
    }
  return raster_picture (ret);
}