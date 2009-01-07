
/******************************************************************************
* MODULE     : hard_link.cpp
* DESCRIPTION: Persistent hard_links between trees
* COPYRIGHT  : (C) 2006  Joris van der Hoeven
*******************************************************************************
* This software falls under the GNU general public license version 3 or later.
* It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
* in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
******************************************************************************/

#include "modification.hpp"
#include "link.hpp"
#include "iterator.hpp"
#include "vars.hpp"

hashmap<string,list<observer> > id_resolve;
hashmap<observer,list<string> > pointer_resolve;
hashmap<tree,list<soft_link> > vertex_occurrences;
hashmap<string,int> type_count (0);

static string current_locus_on_paper= "preserve";
static string current_locus_color= "#404080";
static string current_visited_color= "#702070";

static hashset<string> visited_table;

extern tree the_et;

/******************************************************************************
* Soft links
******************************************************************************/

void
register_pointer (string id, observer which) {
  // cout << "Register: " << id << " -> " << which << "\n";
  // cout << "Register: " << id << " -> " << obtain_tree (which) << "\n";
  list<observer>& l1= id_resolve (id);
  l1= list<observer> (which, l1);
  list<string>& l2= pointer_resolve (which);
  l2= list<string> (id, l2);
}

void
unregister_pointer (string id, observer which) {
  // cout << "Unregister: " << id << " -> " << which << "\n";
  // cout << "Unregister: " << id << " -> " << obtain_tree (which) << "\n";
  list<observer>& l1= id_resolve (id);
  l1= remove (l1, which);
  if (is_nil (l1)) id_resolve->reset (id);
  list<string>& l2= pointer_resolve (which);
  l2= remove (l2, id);
  if (is_nil (l2)) pointer_resolve->reset (which);
}

void
register_vertex (tree v, soft_link ln) {
  list<soft_link>& l= vertex_occurrences (v);
  l= list<soft_link> (ln, l);
}

void
unregister_vertex (tree v, soft_link ln) {
  list<soft_link>& l= vertex_occurrences (v);
  l= remove (l, ln);
  if (is_nil (l)) vertex_occurrences->reset (v);
}

void
register_link (soft_link ln) {
  // cout << "Register: " << ln->t << "\n";
  int i, n= N(ln->t);
  if (is_atomic (ln->t[0]))
    type_count (ln->t[0]->label) ++;
  for (i=1; i<n; i++)
    register_vertex (ln->t[i], ln);
}

void
unregister_link (soft_link ln) {
  // cout << "Unregister: " << ln->t << "\n";
  int i, n= N(ln->t);
  if (is_atomic (ln->t[0])) {
    type_count (ln->t[0]->label) --;
    if (type_count (ln->t[0]->label) == 0)
      type_count->reset (ln->t[0]->label);
  }
  for (i=1; i<n; i++)
    unregister_vertex (ln->t[i], ln);
}

/******************************************************************************
* Link repositories
******************************************************************************/

link_repository_rep::link_repository_rep () {}

link_repository_rep::~link_repository_rep () {
  while (!is_nil (loci)) {
    tree t= obtain_tree (loci->item);
    unregister_pointer (ids->item, loci->item);
    detach_observer (t, loci->item);
    ids= ids->next;
    loci= loci->next;
  }
  while (!is_nil (links)) {
    unregister_link (links->item);
    links= links->next;
  }
}

void
link_repository_rep::insert_locus (string id, tree t) {
  observer obs= tree_pointer (t);
  register_pointer (id, obs);
  attach_observer (t, obs);
  ids= list<string> (id, ids);
  loci= list<observer> (obs, loci);
}

void
link_repository_rep::insert_link (soft_link ln) {
  register_link (ln);
  links= list<soft_link> (ln, links);
}

/******************************************************************************
* Routines for navigation
******************************************************************************/

list<string>
get_ids (list<observer> l) {
  if (is_nil (l)) return list<string> ();
  return pointer_resolve [l->item] * get_ids (l->next);
}

list<string>
get_ids (tree t) {
  if (is_nil (t->obs)) return list<string> ();
  list<observer> l= t->obs->get_tree_pointers ();
  return reverse (get_ids (l));
}

list<tree>
as_trees (list<observer> l) {
  if (is_nil (l)) return list<tree> ();
  else return list<tree> (obtain_tree (l->item), as_trees (l->next));
}

list<tree>
get_trees (string id) {
  return reverse (as_trees (id_resolve [id]));
}

list<tree>
as_tree_list (list<soft_link> l) {
  if (is_nil (l)) return list<tree> ();
  else return list<tree> (l->item->t, as_tree_list (l->next));
}

list<tree>
get_links (tree v) {
  return reverse (as_tree_list (vertex_occurrences [v]));
}

list<string>
all_link_types () {
  list<string> l;
  iterator<string> it= iterate (type_count);
  while (it->busy()) {
    string s= it->next();
    l= list<string> (s, l);
  }
  return l;
}

/******************************************************************************
* Locus rendering
******************************************************************************/

void
set_locus_rendering (string var, string val) {
  if (var == "locus-on-paper") current_locus_on_paper= val;
  if (var == LOCUS_COLOR) current_locus_color= val;
  if (var == VISITED_COLOR) current_visited_color= val;
}

string
get_locus_rendering (string var) {
  if (var == "locus-on-paper") return current_locus_on_paper;
  if (var == LOCUS_COLOR) return current_locus_color;
  if (var == VISITED_COLOR) return current_visited_color;
  return "";
}

void
declare_visited (string id) {
  visited_table->insert (id);
}

bool
has_been_visited (string id) {
  return visited_table->contains (id);
}

/******************************************************************************
* Link event handlers for tree changes
******************************************************************************/

tree&
get_reference (tree& t) {
  path ip= obtain_ip (t);
  if (ip_attached (ip)) return subtree (the_et, reverse (ip));
  else return t;
}

list<tree>
not_done (list<tree> l) {
  if (is_nil (l)) return l;
  else if (is_modifying (get_reference (l->item))) return not_done (l->next);
  return list<tree> (l->item, not_done (l->next));
}

list<tree>
get_mirrors (tree ln, string id) {
  /*
  if (!is_compound (ln, "link", 4) ||
      ln[0] != "mirror" ||
      !is_compound (ln[2], "id", 1) ||
      !is_atomic (ln[2][0]) ||
      !is_compound (ln[3], "id", 1) ||
      !is_atomic (ln[3][0]))
    return list<tree> ();
  if (ln[2][0] == id) return not_done (get_trees (ln[3][0]->label));
  if (ln[3][0] == id) return not_done (get_trees (ln[2][0]->label));
  */
  (void) ln; (void) id;
  return list<tree> ();
}

void
link_announce (tree ln, string id, modification mod) {
  //cout << "Link event " << ln << ", " << id << ", " << mod << "\n";
  for (list<tree> l= get_mirrors (ln, id); !is_nil (l); l= l->next)
    if (is_applicable (l->item, mod))
      apply (get_reference (l->item), copy (mod));
}

void
link_announce (observer obs, modification mod) {
  for (list<string> ids= pointer_resolve [obs];
       !is_nil (ids); ids= ids->next)
    for (list<tree> lns= get_links (compound ("id", ids->item));
	 !is_nil (lns); lns= lns->next)
      link_announce (lns->item, ids->item, mod);
}
