
/******************************************************************************
* MODULE     : edit_footer.cpp
* DESCRIPTION: display interesting information for the user in the footer
* COPYRIGHT  : (C) 1999  Joris van der Hoeven
*******************************************************************************
* This software falls under the GNU general public license and comes WITHOUT
* ANY WARRANTY WHATSOEVER. See the file $TEXMACS_PATH/LICENSE for more details.
* If you don't have this file, write to the Free Software Foundation, Inc.,
* 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
******************************************************************************/

#include "edit_interface.hpp"
#include "convert.hpp"

/******************************************************************************
* Set left footer with information about environment variables
******************************************************************************/

void
edit_interface_rep::set_left_footer (string s) {
  SERVER (set_left_footer (s));
}

void
edit_interface_rep::append_left_footer (string& s, string env_var) {
  string i= get_init_string (env_var);
  string c= get_env_string (env_var);
  if (c != i) s= s * "#" * c;
}

void
edit_interface_rep::set_left_footer () {
  int i;
  string s, r, e;
  double base_sz= get_env_int (FONT_BASE_SIZE);
  double sz= get_env_double (FONT_SIZE);
  tree the_style= get_style ();
  for (i=0; i<arity (the_style); i++)
    s= s * "#" * as_string (the_style[i]);
  string mode= get_env_string (MODE);
  string lan = get_env_string (LANGUAGE (mode));
  if (mode == "prog") s= s * "#program";
  else if (as_string (get_init_value (LANGUAGE (mode))) != lan)
    s= s * "#" * lan;
  else s= s * "#" * mode;
  if (mode == "text") {
    s= s * "#" * get_env_string (TEXT_FONT);
    append_left_footer (s, TEXT_FAMILY);
    s= s * "#" * as_string ((int) ((base_sz+0.5)*sz));
    append_left_footer (s, TEXT_SERIES);
    append_left_footer (s, TEXT_SHAPE);
  }
  else if (mode == "math") {
    s= s * "#" * get_env_string (MATH_FONT);
    append_left_footer (s, MATH_FAMILY);
    s= s * "#" * as_string ((int) ((base_sz+0.5)*sz));
    append_left_footer (s, MATH_SERIES);
    append_left_footer (s, MATH_SHAPE);
  }
  else {
    string session_name= get_env_string (THIS_SESSION);
    if (session_name != "default") s= s * "-" * session_name;
    s= s * "#" * get_env_string (PROG_FONT);
    append_left_footer (s, PROG_FAMILY);
    s= s * "#" * as_string ((int) ((base_sz+0.5)*sz));
    append_left_footer (s, PROG_SERIES);
    append_left_footer (s, PROG_SHAPE);
  }
  r= get_env_string (COLOR);
  if (r != "black") s= s * "#" * r;
  if ((N(s)>0) && (s[0] == '#')) s= s (1, N(s));
  set_left_footer (s);
}

/******************************************************************************
* Set right footer with information about cursor position
******************************************************************************/

void
edit_interface_rep::set_right_footer (string s) {
  SERVER (set_right_footer (s));
}

string
edit_interface_rep::compute_text_footer (tree st) {
  string r;
  language lan= get_env_language ();
  int end  = last_item (tp);
  int start= end;
  if (lan->enc->token_backward (st->label, start))
    fatal_error ("bad cursor position in string",
		 "edit_interface_rep::set_footer");
  r= st->label (start, end);
  if (r == "") r= "start";
  if (r == " ") r= "space";
  if (r == "#") r= "sharp";
  return r;
}

static string
get_accent_type (string s) {
  if (s == "^") return "hat";
  if (s == "~") return "tilde";
  if ((N(s)>=2) && (s[0]=='<') && (s[N(s)-1]=='>')) return s (1, N(s)-1);
  return "unknown accent";
}

inline string
as_symbol (tree t) {
  string s= as_string (t);
  if (N(s)<=1) return s;
  else return "<" * s * ">";
}

static string
get_with_text (tree t) {
  int i, n=N(t), k=(n-1)/2;
  if ((n&1)!=1) return "";
  string s;
  for (i=0; i<k; i++)
    if (is_atomic (t[2*i]) && (t[2*i]!="") && is_atomic (t[2*i+1])) {
      if (i>0) s << "#";
      string var= t[2*i]->label;
      if ((var!=MODE) && (var!=COLOR) && (var!=PAR_MODE) &&
	  (var!=TEXT_LANGUAGE) && (var!=TEXT_FONT) &&
	  (var!=TEXT_FAMILY) && (var!=TEXT_SHAPE) && (var!=TEXT_SERIES) &&
	  (var!=MATH_LANGUAGE) && (var!=MATH_FONT) &&
	  (var!=MATH_FAMILY) && (var!=MATH_SHAPE) && (var!=MATH_SERIES) &&
	  (var!=PROG_LANGUAGE) && (var!=PROG_FONT) &&
	  (var!=PROG_FAMILY) && (var!=PROG_SHAPE) && (var!=PROG_SERIES) &&
	  (var!=THIS_SESSION))
	s << var << "=";
      s << t[2*i+1]->label;
    }
  return s;
}

string
edit_interface_rep::compute_operation_footer (tree st) {
  string r;
  switch (L (st)) {
  case _FLOAT: r= (is_atomic (st[0])? st[0]->label: string ("float")); break;
  case MID: r= "separator#" * as_symbol (st[0]); break;
  case RIGHT: r= "close#" * as_symbol (st[0]); break;
  case BIG: r= "big#" * as_symbol (st[0]); break;
  case LPRIME: r= "left prime#" * as_string (st[0]); break;
  case RPRIME: r= "prime#" * as_string (st[0]); break;
  case SQRT: r= (char*) ((N(st)==1)? "square root": "n-th root"); break;
  case WIDE: r=  get_accent_type (as_string (st[1])); break;
  case VAR_WIDE: r= "under#" * get_accent_type (as_string (st[1])); break;
  case TFORMAT: r= "table"; break;
  case ASSIGN: r= "assign#" * as_string (st[0]); break;
  case WITH: r= "with#" * get_with_text (st); break;
  case PROVIDES: r= "provides#" * as_string (st[0]); break;
  case VALUE: r= "value#" * as_string (st[0]); break;
  case ARG: r= "argument#" * as_string (st[0]); break;
  case COMPOUND: r= "compound#" * as_string (st[0]); break;
  case INCLUDE: r= "include#" * as_string (st[0]); break;
  case INACTIVE: r= "inactive#" * drd->get_name (L(st[0])); break;
  case VAR_INACTIVE: r= "inactive#" * drd->get_name (L(st[0])); break;
  case LABEL: r= "label: " * as_string (st[0]); break;
  case REFERENCE: r= "reference: " * as_string (st[0]); break;
  case PAGEREF: r=  "page reference: " * as_string (st[0]); break;
  case WRITE: r= "write to " * as_string (st[0]); break;
  case SPECIFIC: r= "specific " * as_string (st[0]); break;
  case POSTSCRIPT: r= "postscript image"; break;
  default: r= drd->get_name (L(st));
  }
  if (last_item (tp) == 0) r= "before#" * r;
  return r;
}

string
edit_interface_rep::compute_compound_footer (tree t, path p) {
  if (nil (p) || atom (p)) return "";
  string up= compute_compound_footer (t, path_up (p));
  tree st= subtree (t, path_up (p));
  int  l = last_item (p);
  switch (L (st)) {
  case DOCUMENT:
  case PARA:
    return up;
  case SURROUND:
    if (l == 0) return up * "left surrounding#";
    if (l == 1) return up * "right surrounding#";
    return up;
  case CONCAT:
    return up;
  case MOVE:
    if (l==0) return up * "move#";
    else return up;
  case RESIZE:
    if (l==0) return up * "resize#";
    else return up;
  case _FLOAT:
    if (is_atomic (st[0])) return up * st[0]->label * "#";
    else return up * "float#";
  case BELOW:
    if (l==0) return up * "body#";
    else return up * "script below#";
  case ABOVE:
    if (l==0) return up * "body#";
    else return up * "script above#";
  case FRAC:
    if (l==0) return up * "numerator#";
    else return up * "denominator#";
  case SQRT:
    if (N(st)==1) return up * "square root#";
    if (l==0) return up * "root#";
    else return up * "index#";
  case WIDE:
    return up * get_accent_type (as_string (st[1])) * "#";
  case VAR_WIDE:
    return up * "under#" * get_accent_type (as_string (st[1])) * "#";
  case TREE:
    if (l==0) return up * "root#";
    else return up * "branch(" * as_string (l) * ")#";
  case TFORMAT:
    return up;
  case TABLE:
    return up * "(" * as_string (l+1) * ",";
  case ROW:
    return up * as_string (l+1) * ")#";
  case CELL:
    return up;
  case WITH:
    return up * get_with_text (st) * "#";
  case DRD_PROPS:
    if (l == 0) return up * "drd property(variable)" * "#";
    if ((l&1) == 1) return up * "drd property(" * as_string (l/2+1) * ")#";
    return up * "value(" * as_string (l/2) * ")#";
  case COMPOUND:
    return up * as_string (st[0]) * "#";
  case TUPLE:
    return up * "tuple(" * as_string (l+1) * ")#";
  case ATTR:
    if ((l&1) == 0) return up * "variable(" * as_string (l/2+1) * ")#";
    else return up * "value(" * as_string (l/2+1) * ")#";
  case SPECIFIC:
    return up * "texmacs#";
  case HLINK:
    return up * "hyperlink(" * as_string (st[1]) * ")#";
  default:
    return up * drd->get_name (L(st)) * "#";
  }
}

void
edit_interface_rep::set_right_footer () {
  string s, r;
  tree st= subtree (et, path_up (tp));
  if (is_atomic (st)) r= compute_text_footer (st);
  else r= compute_operation_footer (st);
  r= compute_compound_footer (et, path_up (tp)) * r;
  set_right_footer (r);
}

/******************************************************************************
* Set footer with information about execution of latex command
******************************************************************************/

bool
edit_interface_rep::set_latex_footer (tree st) {
  if (is_atomic (st)) 
    if (is_func (subtree (et, path_up (path_up (tp))), LATEX, 1) ||
	is_func (subtree (et, path_up (path_up (tp))), HYBRID, 1)) {
      string s= st->label;
      string help;
      command cmd;
      if (sv->kbd_get_command (s, help, cmd)) {
	set_left_footer ("return:#" * help);
	set_right_footer ("latex command");
	return true;
      }
    }
  return false;
}

/******************************************************************************
* Update footer
******************************************************************************/

DEBUG
(
  int concrete_count = 0;
  int abstract_count = 0;
  int box_count      = 0;
  int event_count    = 0;
  int widget_count   = 0;
  int line_item_count= 0;
  int list_count     = 0;
  int command_count  = 0;
  int iterator_count = 0;
  int function_count = 0;
  int instance_count = 0;
)

void
edit_interface_rep::set_footer () {
  DEBUG
  (
    cout << "--------------------------------------------------------------\n";
    cout << "concrete  " << concrete_count << "\n";
    cout << "abstract  " << abstract_count << "\n";
    cout << "widget    " << widget_count << "\n";
    cout << "box       " << box_count << "\n";
    cout << "event     " << event_count << "\n";
    cout << "line item " << line_item_count << "\n";
    cout << "list      " << list_count << "\n";
    cout << "command   " << command_count << "\n";
    cout << "iterator  " << iterator_count << "\n";
    cout << "function  " << function_count << "\n";
    cout << "instance  " << instance_count << "\n";
  )

  if ((N(message_l) == 0) && (N(message_r) == 0)) {
    tree st= subtree (et, path_up (tp));
    if (set_latex_footer (st)) return;
    set_left_footer();
    set_right_footer();
  }
  else {
    set_left_footer (message_l);
    set_right_footer (message_r);
    message_l= message_r= "";
  }
}

/******************************************************************************
* Interactive commands
******************************************************************************/

class interactive_command_rep: public command_rep {
  edit_interface_rep* ed;
  scheme_tree p;    // the interactive arguments
  scheme_tree q;    // the function which is applied to the arguments
  int         i;    // counter where we are
  string*     s;    // feedback from interaction with user

public:
  interactive_command_rep (
    edit_interface_rep* Ed, scheme_tree P, scheme_tree Q):
      ed (Ed), p (P), q (Q), i (0), s (new string [N(p)]) {}
  ~interactive_command_rep () { delete[] s; }
  void apply ();
  ostream& print (ostream& out) {
    return out << "interactive command " << p; }
};

void
interactive_command_rep::apply () {
  if ((i>0) && (s[i-1] == "cancel")) return;
  if (i == arity (p)) {
    tree prg (TUPLE, N(p)+1);
    prg[0]= q;
    for (i=0; i<N(p); i++) prg[i+1]= s[i];
    string ret= as_string (eval (scheme_tree_to_string (prg)));
    if ((ret != "") && (ret != "#<unspecified>"))
      ed->set_message (ed->message_l, "interactive command");
  }
  else {
    if ((!is_atomic (p[i])) || (!is_quoted (p[i]->label))) return;
    s[i]= string ("");
    tm_view temp_vw= ed->sv->get_view (false);
    ed->focus_on_this_editor ();
    ed->sv->interactive (unquote (p[i]->label), s[i], this);
    ed->sv->set_view (temp_vw);
    i++;
  }
}

/******************************************************************************
* Exported routines
******************************************************************************/

void
edit_interface_rep::set_message (string l, string r) {
  message_l= l;
  message_r= r;
  notify_change (THE_DECORATIONS);
}

void
edit_interface_rep::interactive (scheme_tree p, scheme_tree q) {
  if (!is_tuple (p))
    fatal_error ("tuple expected", "edit_interface_rep::interactive");
  command interactive_cmd= new interactive_command_rep (this, p, q);
  interactive_cmd ();
}
