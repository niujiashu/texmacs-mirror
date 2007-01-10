
/******************************************************************************
* MODULE     : evaluate_control.cpp
* DESCRIPTION: control structures
* COPYRIGHT  : (C) 2006  Joris van der Hoeven
*******************************************************************************
* This software falls under the GNU general public license and comes WITHOUT
* ANY WARRANTY WHATSOEVER. See the file $TEXMACS_PATH/LICENSE for more details.
* If you don't have this file, write to the Free Software Foundation, Inc.,
* 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
******************************************************************************/

#include "evaluate_main.hpp"
#include "std_environment.hpp"
#include "vars.hpp"
#include "file.hpp"
#include "convert.hpp"
#include "scheme.hpp"

/******************************************************************************
* Classical control structures
******************************************************************************/

tree
evaluate_if (tree t) {
  if (N(t) != 2 && N(t) != 3) return evaluate_error ("bad if");
  tree u= evaluate (t[0]);
  if (!is_bool (u)) return evaluate_error ("bad if");
  if (as_bool (u)) return evaluate (t[1]);
  if (N(t)==3) return evaluate (t[2]);
  return "";
}

tree
evaluate_case (tree t) {
  if (N(t) < 2) return evaluate_error ("bad case");
  int i, n= N(t);
  for (i=0; i<(n-1); i+=2) {
    tree u= evaluate (t[i]);
    if (!is_bool (u)) return evaluate_error ("bad case");
    if (as_bool (u)) return evaluate (t[i+1]);
  }
  if (i<n) return evaluate (t[i]);
  return "";
}

tree
evaluate_while (tree t) {
  if (N(t) != 2) return evaluate_error ("bad while");
  tree r (CONCAT);
  while (true) {
    tree u= evaluate (t[0]);
    if (!is_bool (u)) return evaluate_error ("bad while");
    if (!as_bool (u)) break;
    r << evaluate (t[1]);
  }
  if (N(r) == 0) return "";
  if (N(r) == 1) return r[0];
  return r;
}

tree
evaluate_for_each (tree t) {
  if (N(t) != 2) return evaluate_error ("bad for-each");
  tree fun = evaluate (t[0]);
  tree args= evaluate (t[1]);
  if (!is_tuple (args)) return evaluate_error ("bad for-each");
  int i, n= N(args);
  for (i=0; i<n; i++)
    evaluate (tree (COMPOUND, fun, args[i]));
  return "";
}

/******************************************************************************
* External dependencies
******************************************************************************/

static tree
filter_style (tree t) {
  if (is_atomic (t)) return t;
  else switch (L(t)) {
  case STYLE_WITH:
  case VAR_STYLE_WITH:
    return filter_style (t[N(t)-1]);
  case STYLE_ONLY:
  case VAR_STYLE_ONLY:
    if (is_atomic (t[0])) return "";
    else return filter_style (t[0][N(t[0])-1]);
  case ACTIVE:
  case VAR_ACTIVE:
  case INACTIVE:
  case VAR_INACTIVE:
    return filter_style (t[0]);
  default:
    {
      int i, n= N(t);
      tree r (t, n);
      for (i=0; i<n; i++)
	r[i]= filter_style (t[i]);
      return r;
    }
  }
}

tree
evaluate_use_package (tree t) {
  int i, n= N(t);
  for (i=0; i<n; i++) {
    url base_file_name (as_string (std_env["base-file-name"]));
    url styp= "$TEXMACS_STYLE_PATH";
    url name= as_string (t[i]) * string (".ts");
    //cout << "Package " << name << "\n";
    if (is_rooted_web (base_file_name))
      styp= styp | head (base_file_name);
    else styp= head (base_file_name) | styp;
    string doc_s;
    if (!load_string (styp * name, doc_s, false)) {
      tree doc= texmacs_document_to_tree (doc_s);
      if (is_compound (doc))
	evaluate (filter_style (extract (doc, "body")));
    }
  }
  return "";
}

tree
evaluate_use_module (tree t) {
  int i, n= N(t);
  for (i=0; i<n; i++) {
    string s= as_string (evaluate (t[i]));
    if (starts (s, "(")) eval ("(use-modules " * s * ")");
    else if (s != "") eval ("(plugin-initialize '" * s * ")");
    tree t= std_env[THE_MODULES] * tuple (s);
    assoc_environment local (1);
    local->raw_write (0, THE_MODULES, t);
    assign (std_env, local);
  }
  return "";
}
