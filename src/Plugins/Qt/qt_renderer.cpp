
/******************************************************************************
* MODULE     : qt_renderer.cpp
* DESCRIPTION: QT drawing interface class
* COPYRIGHT  : (C) 2008 Massimiliano Gubinelli
*******************************************************************************
* This software falls under the GNU general public license version 3 or later.
* It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
* in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
******************************************************************************/

#include "qt_renderer.hpp"
#include "analyze.hpp"
#include "image_files.hpp"
#include "qt_utilities.hpp"
#include "file.hpp"
#include "image_files.hpp"
#include "scheme.hpp"
#include "frame.hpp"

#include <QObject>
#include <QWidget>
#include <QPaintDevice>
#include <QPixmap>

/******************************************************************************
* Qt images
******************************************************************************/

struct qt_image_rep: concrete_struct {
  QTMImage *img;
  SI xo,yo;
  int w,h;
  qt_image_rep (QTMImage* img2, SI xo2, SI yo2, int w2, int h2):
    img (img2), xo (xo2), yo (yo2), w (w2), h (h2) {};
  ~qt_image_rep() { delete img; };
  friend class qt_image;
};

class qt_image {
CONCRETE_NULL(qt_image);
  qt_image (QTMImage* img2, SI xo2, SI yo2, int w2, int h2):
    rep (tm_new<qt_image_rep> (img2, xo2, yo2, w2, h2)) {};
  // qt_image ();
};

CONCRETE_NULL_CODE(qt_image);

/******************************************************************************
 * Qt pixmaps
 ******************************************************************************/

struct qt_pixmap_rep: concrete_struct {
  QPixmap *img;
  SI xo,yo;
  int w,h;
  qt_pixmap_rep (QPixmap* img2, SI xo2, SI yo2, int w2, int h2):
    img (img2), xo (xo2), yo (yo2), w (w2), h (h2) {};
  ~qt_pixmap_rep()  { delete img; };
  friend class qt_pixmap;
};

class qt_pixmap {
CONCRETE_NULL(qt_pixmap);
  qt_pixmap (QPixmap* img2, SI xo2, SI yo2, int w2, int h2):
    rep (tm_new<qt_pixmap_rep> (img2, xo2, yo2, w2, h2)) {};
  // qt_pixmap ();
};

CONCRETE_NULL_CODE(qt_pixmap);

/******************************************************************************
* Global support variables for all qt_renderers
******************************************************************************/

// bitmaps of all characters
static hashmap<basic_character,qt_image> character_image;  
// image cache
static hashmap<string,qt_pixmap> images;

/******************************************************************************
* qt_renderer
******************************************************************************/

qt_renderer_rep::qt_renderer_rep (QPainter *_painter, int w2, int h2):
  basic_renderer_rep (true, w2, h2), painter(_painter) {}

qt_renderer_rep::~qt_renderer_rep () {}

void*
qt_renderer_rep::get_handle () {
  return (void*) this;
}

void
qt_renderer_rep::begin (void* handle) {
  QPaintDevice *device = static_cast<QPaintDevice*>(handle);
  if (!painter->begin (device) && DEBUG_QT)
    cout << "qt_renderer_rep::begin(): uninitialized QPixmap of size "
         << ((QPixmap*)handle)->width() << " x " << ((QPixmap*)handle)->height()
         << LF;
    
  w = painter->device()->width();
  h = painter->device()->height();
}

void qt_renderer_rep::end () { painter->end (); }

void 
qt_renderer_rep::get_extents (int& w2, int& h2) {  
  if (painter->device()) {
    w2 = painter->device()->width(); h2 = painter->device()->height();
  } else {
    w2 = w; h2 = h;
  }
}

/******************************************************************************
* Transformations
******************************************************************************/

void
qt_renderer_rep::set_transformation (frame fr) {
  ASSERT (fr->linear, "only linear transformations have been implemented");

  SI cx1, cy1, cx2, cy2;
  get_clipping (cx1, cy1, cx2, cy2);
  rectangle oclip (cx1, cy1, cx2, cy2);

  frame cv= scaling (point (pixel, -pixel), point (-ox, -oy));
  frame tr= invert (cv) * fr * cv;
  point o = tr (point (0.0, 0.0));
  point ux= tr (point (1.0, 0.0)) - o;
  point uy= tr (point (0.0, 1.0)) - o;
  //cout << "Set transformation " << o << ", " << ux << ", " << uy << "\n";
  QTransform qtr (ux[0], ux[1], uy[0], uy[1], o[0], o[1]);
  painter->save ();
  painter->setTransform (qtr, true);

  rectangle nclip= fr [oclip];
  clip (nclip->x1, nclip->y1, nclip->x2, nclip->y2);
}

void
qt_renderer_rep::reset_transformation () {
  unclip ();
  painter->restore ();
}

/******************************************************************************
* Clipping
******************************************************************************/

void
qt_renderer_rep::set_clipping (SI x1, SI y1, SI x2, SI y2, bool restore)
{
  (void) restore;
  basic_renderer_rep::set_clipping (x1, y1, x2, y2);
  outer_round (x1, y1, x2, y2);
  decode (x1, y1);
  decode (x2, y2);
  if ((x1<x2) && (y2<y1)) {
    QRect r(x1,y2,x2-x1,y1-y2);
    painter->setClipRect(r);
  } else {
    painter->setClipRect(QRect());
  }
}

/******************************************************************************
* Drawing 
******************************************************************************/

void
qt_renderer_rep::set_color (color c) {
  basic_renderer_rep::set_color (c);
  QPen p (painter->pen ());
  QBrush b (painter->brush ());
  p.setColor (to_qcolor (cur_fg));
  b.setColor (to_qcolor (cur_fg));
  painter->setPen (p);
  painter->setBrush (b);
}

bool is_percentage (tree t, string s= "%");
double as_percentage (tree t);

void
qt_renderer_rep::set_brush (brush br) {
  basic_renderer_rep::set_brush (br);
  QPen p (painter->pen ());
  QBrush b (painter->brush ());
  p.setColor (to_qcolor (cur_fg));
  b.setColor (to_qcolor (cur_fg));
  painter->setPen (p);
  painter->setBrush (b);
  if (br->kind == brush_pattern) {
    tree pattern= br->pattern;
    int pattern_alpha= br->alpha;

    url u= as_string (pattern[0]);
    int imw_pt, imh_pt;
    image_size (u, imw_pt, imh_pt);
    double pt= ((double) 600*PIXEL) / 72.0;
    SI imw= (SI) (((double) imw_pt) * pt);
    SI imh= (SI) (((double) imh_pt) * pt);

    SI w= imw, h= imh;
    if (is_int (pattern[1])) w= as_int (pattern[1]);
    else if (is_percentage (pattern[1]))
      w= (SI) (as_percentage (pattern[1]) * ((double) w));
    else if (is_percentage (pattern[1], "@"))
      w= (SI) (as_percentage (pattern[1]) * ((double) h));
    if (is_int (pattern[2])) h= as_int (pattern[2]);
    else if (is_percentage (pattern[2]))
      h= (SI) (as_percentage (pattern[2]) * ((double) h));
    else if (is_percentage (pattern[2], "@"))
      h= (SI) (as_percentage (pattern[2]) * ((double) w));
    w= ((w + pixel - 1) / pixel);
    h= ((h + pixel - 1) / pixel);
    QImage* pm= get_image (u, w, h);

    painter->setOpacity (qreal (pattern_alpha) / qreal (255));
    if (pm != NULL) painter->setBrush (QBrush (*pm));
  }
}

void
qt_renderer_rep::set_line_style (SI lw, int type, bool round) {
  (void) type;
  QPen p (painter->pen ());
  if (lw <= pixel) p.setWidth (0);
  else p.setWidth ((lw+thicken) / (1.0*pixel));
  p.setCapStyle (round? Qt::RoundCap: Qt::SquareCap);
  p.setJoinStyle (Qt::RoundJoin);
  painter->setPen (p);
}

void
qt_renderer_rep::line (SI x1, SI y1, SI x2, SI y2) {
  decode (x1, y1);
  decode (x2, y2);
  // y1--; y2--; // top-left origin to bottom-left origin conversion
  painter->setRenderHints (QPainter::Antialiasing);
  painter->drawLine (x1, y1, x2, y2);
}

void
qt_renderer_rep::lines (array<SI> x, array<SI> y) {
  int i, n= N(x);
  if ((N(y) != n) || (n<1)) return;
  STACK_NEW_ARRAY (pnt, QPoint, n);
  for (i=0; i<n; i++) {
    SI xx= x[i], yy= y[i];
    decode (xx, yy);
    pnt[i].rx()= xx;
    pnt[i].ry()= yy;
    if (i>0) {
      painter->setRenderHints (QPainter::Antialiasing);
      painter->drawLine (pnt[i-1], pnt[i]); // FIX: hack
    }
  }
  // XDrawLines (dpy, win, gc, pnt, n, CoordModeOrigin);
  STACK_DELETE_ARRAY (pnt);
}

void
qt_renderer_rep::clear (SI x1, SI y1, SI x2, SI y2) {
  x1= max (x1, cx1-ox); y1= max (y1, cy1-oy);
  x2= min (x2, cx2-ox); y2= min (y2, cy2-oy);
  // outer_round (x1, y1, x2, y2); might still be needed somewhere
  decode (x1, y1);
  decode (x2, y2);
  if ((x1>=x2) || (y1<=y2)) return;
  QBrush br (to_qcolor(cur_bg));
  painter->setRenderHints (0);
  painter->fillRect (x1, y2, x2-x1, y1-y2, br);       
}

void
qt_renderer_rep::fill (SI x1, SI y1, SI x2, SI y2) {
  if ((x2>x1) && ((x2-x1)<pixel)) {
    SI d= pixel-(x2-x1);
    x1 -= (d>>1);
    x2 += ((d+1)>>1);
  }
  if ((y2>y1) && ((y2-y1)<pixel)) {
    SI d= pixel-(y2-y1);
    y1 -= (d>>1);
    y2 += ((d+1)>>1);
  }

  x1= max (x1, cx1-ox); y1= max (y1, cy1-oy);
  x2= min (x2, cx2-ox); y2= min (y2, cy2-oy);
  // outer_round (x1, y1, x2, y2); might still be needed somewhere
  if ((x1>=x2) || (y1>=y2)) return;

  decode (x1, y1);
  decode (x2, y2);

  QBrush br (to_qcolor(cur_fg));
  painter->setRenderHints (0);
  painter->fillRect (x1, y2, x2-x1, y1-y2, br);       
}

void
qt_renderer_rep::arc (SI x1, SI y1, SI x2, SI y2, int alpha, int delta) {
  if ((x1>=x2) || (y1>=y2)) return;
  decode (x1, y1);
  decode (x2, y2);
  painter->setRenderHints (QPainter::Antialiasing);
  painter->drawArc (x1, y2, x2-x1, y1-y2, alpha / 4, delta / 4);
}

void
qt_renderer_rep::fill_arc (SI x1, SI y1, SI x2, SI y2, int alpha, int delta) {
  if ((x1>=x2) || (y1>=y2)) return;
  decode (x1, y1);
  decode (x2, y2);
  QBrush br(to_qcolor(cur_fg));
  QPainterPath pp;
  pp.arcMoveTo (x1, y2, x2-x1, y1-y2, alpha / 64);
  pp.arcTo (x1, y2, x2-x1, y1-y2, alpha / 64, delta / 64);
  pp.closeSubpath ();
  pp.setFillRule (Qt::WindingFill);
  painter->setRenderHints (QPainter::Antialiasing);
  painter->fillPath (pp, br);
}

void
qt_renderer_rep::polygon (array<SI> x, array<SI> y, bool convex) {
  int i, n= N(x);
  if ((N(y) != n) || (n<1)) return;
  QPolygonF poly(n);
  for (i=0; i<n; i++) {
    SI xx= x[i], yy= y[i];
    decode (xx, yy);
    poly[i] = QPointF (xx, yy);
  }
  QBrush br= painter->brush ();
  if (fg_brush->kind != brush_pattern)
    // FIXME: is this really necessary?
    // The brush should have been set at the moment of set_color or set_brush
    br= QBrush (to_qcolor (cur_fg));
  QPainterPath pp;
  pp.addPolygon (poly);
  pp.closeSubpath ();
  pp.setFillRule (convex? Qt::OddEvenFill: Qt::WindingFill);
  painter->setRenderHints (QPainter::Antialiasing);
  painter->fillPath (pp, br);
}


/******************************************************************************
* Image rendering
******************************************************************************/

void
qt_renderer_rep::image (url u, SI w, SI h, SI x, SI y, int alpha) {
  // Given an image of original size (W, H),
  // we display it at position (x, y) in a rectangle of size (w, h)
  w= w/pixel; h= h/pixel;
  decode (x, y);

  // safety check
  url ru = resolve(u);
  u = is_none (ru) ? "$TEXMACS_PATH/misc/pixmaps/unknown.ps" : ru;
  
  QImage* pm= get_image (u, w, h);
  if (pm == NULL) return;

  qreal old_opacity= painter->opacity ();
  painter->setOpacity (qreal (alpha) / qreal (255));
  painter->drawImage (x, y-h, *pm);
  painter->setOpacity (old_opacity);
};


void
qt_renderer_rep::draw_clipped (QImage *im, int w, int h, SI x, SI y) {
  (void) w; (void) h;
  int x1=cx1-ox, y1=cy2-oy, x2= cx2-ox, y2= cy1-oy;
  decode (x , y );
  decode (x1, y1);
  decode (x2, y2);
  y--; // top-left origin to bottom-left origin conversion
       // clear(x1,y1,x2,y2);
  painter->setRenderHints (0);
  painter->drawImage (x, y, *im);
}

void
qt_renderer_rep::draw_clipped (QPixmap *im, int w, int h, SI x, SI y) {
  decode (x , y );
  y--; // top-left origin to bottom-left origin conversion
  // clear(x1,y1,x2,y2);
  painter->setRenderHints (0);
  painter->drawPixmap (x, y, w, h, *im);
}

void
qt_renderer_rep::draw (int c, font_glyphs fng, SI x, SI y) {
  // get the pixmap
  basic_character xc (c, fng, std_shrinkf, cur_fg, 0);
  qt_image mi = character_image [xc];
  if (is_nil(mi)) {
    int r, g, b, a;
    get_rgb (cur_fg, r, g, b, a);
    SI xo, yo;
    glyph pre_gl= fng->get (c); if (is_nil (pre_gl)) return;
    glyph gl= shrink (pre_gl, std_shrinkf, std_shrinkf, xo, yo);
    int i, j, w= gl->width, h= gl->height;
#ifdef QTMPIXMAPS
    QTMImage *im = new QPixmap(w,h);
    {
      int nr_cols= std_shrinkf*std_shrinkf;
      if (nr_cols >= 64) nr_cols= 64;

      im->fill (Qt::transparent);
      QPainter pp(im);
      QPen pen(painter->pen());
      QBrush br(pen.color());
      pp.setPen(Qt::NoPen);
      for (j=0; j<h; j++)
        for (i=0; i<w; i++) {
          int col = gl->get_x (i, j);
          br.setColor (QColor (r, g, b, (a*col)/nr_cols));
          pp.fillRect (i, j, 1, 1, br);
        }
      pp.end();
    }
#else
    QTMImage *im= new QImage (w, h, QImage::Format_ARGB32);
    //QTMImage *im= new QImage (w, h, QImage::Format_ARGB32_Premultiplied);
    {
      int nr_cols= std_shrinkf*std_shrinkf;
      if (nr_cols >= 64) nr_cols= 64;

      // the following line is disabled because
      // it causes a crash on Qt/X11 4.4.3
      //im->fill (Qt::transparent);

      for (j=0; j<h; j++)
        for (i=0; i<w; i++) {
          int col = gl->get_x (i, j);
          im->setPixel (i, j, qRgba (r, g, b, (a*col)/nr_cols));
        }
    }
#endif
    qt_image mi2 (im, xo, yo, w, h);
    mi = mi2;
    //[im release]; // qt_image retains im
    character_image (xc)= mi;
    // FIXME: we must release the image at some point 
    //        (this should be ok now, see qt_image)
  }

  // draw the character
  //cout << (char)c << ": " << cx1/256 << ","  << cy1/256 << ","  
  //<< cx2/256 << ","  << cy2/256 << LF; 
  draw_clipped (mi->img, mi->w, mi->h, x- mi->xo*std_shrinkf, y+ mi->yo*std_shrinkf);
}

void
qt_renderer_rep::draw (const QFont& qfn, const QString& qs,
                       SI x, SI y, double zoom) {
  decode (x, y);
  painter->setFont (qfn);
  painter->translate (x, y);
  painter->scale (zoom, zoom);
  painter->drawText (0, 0, qs);
  painter->resetTransform ();
}

/******************************************************************************
* Setting up and displaying xpm pixmaps
******************************************************************************/

extern int char_clip;
/*! Loads and caches pixmaps.
 
 Returns a newly allocated QPixmap object or one from the cache.
 */
QPixmap*
qt_renderer_rep::xpm_image (url file_name) {
  QPixmap *pxm= NULL;
  qt_pixmap mi= images [as_string (file_name)];
  if (is_nil (mi)) {
    string sss;
    if (suffix (file_name) == "xpm") {
      url png_equiv= glue (unglue (file_name, 3), "png");
      load_string ("$TEXMACS_PIXMAP_PATH" * png_equiv, sss, false);
    }
    if (sss == "")
      load_string ("$TEXMACS_PIXMAP_PATH" * file_name, sss, false);
    if (sss == "")
      load_string ("$TEXMACS_PATH/misc/pixmaps/TeXmacs.xpm", sss, true);
    c_string buf (sss);
    pxm= new QPixmap();
    pxm->loadFromData ((uchar*)(char*)buf, N(sss));
    //out << sss;
    //cout << "pxm: " << file_name << "(" << pxm->size().width()
    //     << "," <<  pxm->size().height() << ")\n";
    qt_pixmap mi2 (pxm, 0, 0, pxm->width(), pxm->height());
    mi= mi2;
    images (as_string (file_name))= mi2;
  }
  else pxm=  mi->img ;
  return pxm;
}

void
qt_renderer_rep::xpm (url file_name, SI x, SI y) {
  y -= pixel; // counter balance shift in draw_clipped
  QPixmap* image = xpm_image (file_name);
  ASSERT (pixel == PIXEL, "pixel and PIXEL should coincide");
  int w, h;
  w = image->width ();
  h = image->height ();
  int old_clip= char_clip;
  char_clip= true;
  draw_clipped (image, w, h, x, y);
  char_clip=old_clip;
}

/******************************************************************************
 * main qt renderer
 ******************************************************************************/


qt_renderer_rep*
the_qt_renderer () {
  static QPainter *the_painter = NULL;
  static qt_renderer_rep* the_renderer= NULL;
  if (!the_renderer) {
    the_painter = new QPainter();
    the_renderer= tm_new<qt_renderer_rep> (the_painter);
  }
  return the_renderer;
}


/******************************************************************************
 * Shadow management methods 
 ******************************************************************************/

/* Shadows are auxiliary renderers which allow double buffering and caching of
 * graphics. TeXmacs has explicit double buffering from the X11 port. Maybe
 * it would be better to design a better API abstracting from the low level 
 * details but for the moment the following code and the qt_proxy_renderer_rep
 * and qt_shadow_renderer_rep classes are designed to solve two problems:
 * 
 * 1) Qt has already double buffering.
 * 2) in Qt we are not easily allowed to read onscreen pixels (we can only ask a
 *    widget to redraw himself on a pixmap or read the screen pixels -- this has
 *    the drawback that if our widget is under another one we won't read the 
 *    right pixels)
 * 
 * qt_proxy_renderer_rep solves the double buffering problem: when texmacs asks
 * a qt_renderer_rep for a shadow it is given a proxy of the original renderer
 * texmacs uses this shadow for double buffering and the proxy will simply
 * forward the drawing operations to the original surface and neglect all the
 * syncronization operations
 *
 * to solve the second problem we do not draw directly on screen in QTMWidget.
 * Instead we maintain an internal pixmap which represents the state of the pixels
 * according to texmacs. When we are asked to initialize a qt_shadow_renderer_rep
 * we simply read the pixels form this backing store. At the Qt level then
 * (in QTMWidget) we make sure that the state of the backing store is in sync
 * with the screen via paintEvent/repaint mechanism.
 *
 */


void
qt_renderer_rep::new_shadow (renderer& ren) {
  SI mw, mh, sw, sh;
  get_extents (mw, mh);
  if (ren != NULL) {
    ren->get_extents (sw, sh);
    if (sw != mw || sh != mh) {
      delete_shadow (ren);
      ren= NULL;
    }
    // cout << "Old: " << sw << ", " << sh << "\n";
  }
  if (ren == NULL)  ren= (renderer) tm_new<qt_proxy_renderer_rep> (this);
  
  // cout << "Create " << mw << ", " << mh << "\n";
}

void 
qt_renderer_rep::delete_shadow (renderer& ren)  {
  if (ren != NULL) {
    tm_delete (ren);
    ren= NULL;
  }
}

void 
qt_renderer_rep::get_shadow (renderer ren, SI x1, SI y1, SI x2, SI y2) {
  // FIXME: we should use the routine fetch later
  ASSERT (ren != NULL, "invalid renderer");
  if (ren->is_printer ()) return;
  qt_renderer_rep* shadow= static_cast<qt_renderer_rep*>(ren);
  outer_round (x1, y1, x2, y2);
  x1= max (x1, cx1- ox);
  y1= max (y1, cy1- oy);
  x2= min (x2, cx2- ox);
  y2= min (y2, cy2- oy);
  shadow->ox= ox;
  shadow->oy= oy;
  shadow->master= this;
  shadow->cx1= x1+ ox;
  shadow->cy1= y1+ oy;
  shadow->cx2= x2+ ox;
  shadow->cy2= y2+ oy;
  
  decode (x1, y1);
  decode (x2, y2);
  if (x1<x2 && y2<y1) {
    QRect rect = QRect(x1, y2, x2-x1, y1-y2);
    //    shadow->painter->setCompositionMode(QPainter::CompositionMode_Source);  
    shadow->painter->setClipRect(rect);
//    shadow->painter->drawPixmap (rect, px, rect);
    //    cout << "qt_shadow_renderer_rep::get_shadow " 
    //         << rectangle(x1,y2,x2,y1) << LF;
    //  XCopyArea (dpy, win, shadow->win, gc, x1, y2, x2-x1, y1-y2, x1, y2);
  } else {
    shadow->painter->setClipRect(QRect());
  }
}

void 
qt_renderer_rep::put_shadow (renderer ren, SI x1, SI y1, SI x2, SI y2) {
  // FIXME: we should use the routine fetch later
  ASSERT (ren != NULL, "invalid renderer");
  if (ren->is_printer ()) return;
  if (painter == static_cast<qt_renderer_rep*>(ren)->painter) return;
  qt_shadow_renderer_rep* shadow= static_cast<qt_shadow_renderer_rep*>(ren);
  outer_round (x1, y1, x2, y2);
  x1= max (x1, cx1- ox);
  y1= max (y1, cy1- oy);
  x2= min (x2, cx2- ox);
  y2= min (y2, cy2- oy);
  decode (x1, y1);
  decode (x2, y2);
  if (x1<x2 && y2<y1) {
    QRect rect = QRect(x1, y2, x2-x1, y1-y2);
    //    cout << "qt_shadow_renderer_rep::put_shadow " 
    //         << rectangle(x1,y2,x2,y1) << LF;
    //    painter->setCompositionMode(QPainter::CompositionMode_Source);
    painter->drawPixmap (rect, shadow->px, rect);
    //  XCopyArea (dpy, shadow->win, win, gc, x1, y2, x2-x1, y1-y2, x1, y2);
  }
}


void 
qt_renderer_rep::apply_shadow (SI x1, SI y1, SI x2, SI y2)  {
  if (master == NULL) return;
  if (painter == static_cast<qt_renderer_rep*>(master)->painter) return;
  outer_round (x1, y1, x2, y2);
  decode (x1, y1);
  decode (x2, y2);
  static_cast<qt_renderer_rep*>(master)->encode (x1, y1);
  static_cast<qt_renderer_rep*>(master)->encode (x2, y2);
  master->put_shadow (this, x1, y1, x2, y2);
}


/******************************************************************************
* proxy qt renderer
******************************************************************************/

void 
qt_proxy_renderer_rep::new_shadow (renderer& ren) {
  SI mw, mh, sw, sh;
  get_extents (mw, mh);
  if (ren != NULL) {
    ren->get_extents (sw, sh);
    if (sw != mw || sh != mh) {
      delete_shadow (ren);
      ren= NULL;
    }
    else 
      static_cast<qt_shadow_renderer_rep*>(ren)->end();
    // cout << "Old: " << sw << ", " << sh << "\n";
  }
  if (ren == NULL)  
    ren= (renderer) tm_new<qt_shadow_renderer_rep> (QPixmap (mw, mh));
  
  // cout << "Create " << mw << ", " << mh << "\n";
  static_cast<qt_shadow_renderer_rep*>(ren)->begin(
          &(static_cast<qt_shadow_renderer_rep*>(ren)->px));
}

void 
qt_proxy_renderer_rep::get_shadow (renderer ren, SI x1, SI y1, SI x2, SI y2) {
  // FIXME: we should use the routine fetch later
  ASSERT (ren != NULL, "invalid renderer");
  if (ren->is_printer ()) return;
  qt_renderer_rep* shadow= static_cast<qt_renderer_rep*>(ren);
  outer_round (x1, y1, x2, y2);
  x1= max (x1, cx1- ox);
  y1= max (y1, cy1- oy);
  x2= min (x2, cx2- ox);
  y2= min (y2, cy2- oy);
  shadow->ox= ox;
  shadow->oy= oy;
  shadow->cx1= x1+ ox;
  shadow->cy1= y1+ oy;
  shadow->cx2= x2+ ox;
  shadow->cy2= y2+ oy;
  shadow->master= this;
  decode (x1, y1);
  decode (x2, y2);
  if (x1<x2 && y2<y1) {
    QRect rect = QRect(x1, y2, x2-x1, y1-y2);

    shadow->painter->setClipRect(rect);

    //    shadow->painter->setCompositionMode(QPainter::CompositionMode_Source);
    QPixmap *_pixmap = static_cast<QPixmap*>(painter->device()); 
    if (_pixmap) {
      shadow->painter->drawPixmap (rect, *_pixmap, rect);
    }
    //    cout << "qt_shadow_renderer_rep::get_shadow " 
    //         << rectangle(x1,y2,x2,y1) << LF;
    //  XCopyArea (dpy, win, shadow->win, gc, x1, y2, x2-x1, y1-y2, x1, y2);
  } else {
    shadow->painter->setClipRect(QRect());
  }

}


/******************************************************************************
 * shadow qt renderer
 ******************************************************************************/

qt_shadow_renderer_rep::qt_shadow_renderer_rep (QPixmap _px) 
// : qt_renderer_rep (_px.width(),_px.height()), px(_px) 
: qt_renderer_rep (new QPainter()), px(_px) 
{ 
  //cout << px.width() << "," << px.height() << " " << LF;
 // painter->begin(&px);
}

qt_shadow_renderer_rep::~qt_shadow_renderer_rep () 
{ 
  painter->end(); 
  delete painter;
  painter = NULL;
}

void 
qt_shadow_renderer_rep::get_shadow (renderer ren, SI x1, SI y1, SI x2, SI y2) {
  // FIXME: we should use the routine fetch later
  ASSERT (ren != NULL, "invalid renderer");
  if (ren->is_printer ()) return;
  qt_shadow_renderer_rep* shadow= static_cast<qt_shadow_renderer_rep*>(ren);
  outer_round (x1, y1, x2, y2);
  x1= max (x1, cx1- ox);
  y1= max (y1, cy1- oy);
  x2= min (x2, cx2- ox);
  y2= min (y2, cy2- oy);
  shadow->ox= ox;
  shadow->oy= oy;
  shadow->cx1= x1+ ox;
  shadow->cy1= y1+ oy;
  shadow->cx2= x2+ ox;
  shadow->cy2= y2+ oy;
  shadow->master= this;
  decode (x1, y1);
  decode (x2, y2);
  if (x1<x2 && y2<y1) {
    QRect rect = QRect(x1, y2, x2-x1, y1-y2);
    shadow->painter->setClipRect(rect);

//    shadow->painter->setCompositionMode(QPainter::CompositionMode_Source);   
    shadow->painter->drawPixmap (rect, px, rect);
//    cout << "qt_shadow_renderer_rep::get_shadow " 
//         << rectangle(x1,y2,x2,y1) << LF;
//  XCopyArea (dpy, win, shadow->win, gc, x1, y2, x2-x1, y1-y2, x1, y2);
  } else {
    shadow->painter->setClipRect(QRect());
  }
}
