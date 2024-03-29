
/******************************************************************************
* MODULE     : language.cpp
* COPYRIGHT  : (C) 1999  Joris van der Hoeven
*******************************************************************************
* This software falls under the GNU general public license version 3 or later.
* It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
* in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
******************************************************************************/

#include "impl_language.hpp"
#include "packrat.hpp"

RESOURCE_CODE(language);

text_property_rep global_tpr;

text_property_rep tp_normal_rep
  (TP_NORMAL);
text_property_rep tp_hyph_rep
  (TP_HYPH, SPC_NONE, SPC_NONE, 0, 0);
text_property_rep tp_thin_space_rep
  (TP_THIN_SPACE, SPC_NONE, SPC_THIN_SPACE, 0, 0);
text_property_rep tp_space_rep
  (TP_SPACE, SPC_NONE, SPC_SPACE, 0, 0);
text_property_rep tp_dspace_rep
  (TP_DSPACE, SPC_NONE, SPC_DSPACE, 0, 0);
text_property_rep tp_nb_thin_space_rep
  (TP_NB_THIN_SPACE, SPC_NONE, SPC_THIN_SPACE, 0, HYPH_INVALID);
text_property_rep tp_nb_space_rep
  (TP_NB_SPACE, SPC_NONE, SPC_SPACE, 0, HYPH_INVALID);
text_property_rep tp_nb_dspace_rep
  (TP_NB_DSPACE, SPC_NONE, SPC_DSPACE, 0, HYPH_INVALID);
text_property_rep tp_period_rep
  (TP_PERIOD, SPC_NONE, SPC_PERIOD, 0, 0);
text_property_rep tp_half_rep
  (TP_OPERATOR, SPC_NONE, SPC_HALF, 0, HYPH_INVALID);
text_property_rep tp_operator_rep
  (TP_OPERATOR, SPC_NONE, SPC_OPERATOR, 0, HYPH_INVALID);
text_property_rep tp_shortop_rep
  (TP_SHORTOP, SPC_NONE, SPC_TINY, 0, HYPH_INVALID);
text_property_rep tp_cjk_normal_rep
  (TP_CJK_NORMAL, SPC_NONE, SPC_CJK_NORMAL, 0, 0);
text_property_rep tp_cjk_no_break_rep
  (TP_CJK_NO_BREAK, SPC_NONE, SPC_CJK_NORMAL, 0, HYPH_INVALID);
text_property_rep tp_cjk_period_rep
  (TP_CJK_PERIOD, SPC_NONE, SPC_CJK_PERIOD, HYPH_INVALID, 0);
text_property_rep tp_cjk_no_break_period_rep
  (TP_CJK_PERIOD, SPC_NONE, SPC_CJK_PERIOD, HYPH_INVALID, HYPH_INVALID);

/******************************************************************************
* Text properties
******************************************************************************/

text_property_rep::text_property_rep (
  int type2, int spc_before2, int spc_after2,
  int pen_before2, int pen_after2,
  int op_type2, int priority2, int limits2):
    type (type2),
    spc_before (spc_before2), spc_after (spc_after2),
    pen_before (pen_before2), pen_after (pen_after2),
    op_type (op_type2), priority (priority2), limits (limits2) {}

bool
operator == (text_property_rep tpr1, text_property_rep tpr2) {
  return
    (tpr1.type == tpr2.type) &&
    (tpr1.spc_before == tpr2.spc_before) &&
    (tpr1.spc_after == tpr2.spc_after) &&
    (tpr1.pen_before == tpr2.pen_before) &&
    (tpr1.pen_after == tpr2.pen_after) &&
    (tpr1.op_type == tpr2.op_type) &&
    (tpr1.priority == tpr2.priority) &&
    (tpr1.limits == tpr2.limits);
}

bool
operator != (text_property_rep tpr1, text_property_rep tpr2) {
  return !(tpr1 == tpr2);
}

/******************************************************************************
* Initialized the allowed successions of mathematical operators
******************************************************************************/

int succession_status_table [OP_TOTAL * OP_TOTAL];

/*
int
succession_status (int op1, int op2) {
  cout << "Check " << op1 << ":" << op2 << " -> " <<
    succession_status_table [op1 * OP_TOTAL + op2] << "\n";
  return succession_status_table [op1 * OP_TOTAL + op2];
}
*/

static inline void set_status (int op1, int op2, int st) {
  succession_status_table [op1 * OP_TOTAL + op2]= st; }

static inline void init_could_end (int op) {
  set_status (op, OP_UNARY, REMOVE_CURRENT_SPACE);
  set_status (op, OP_N_ARY, REMOVE_CURRENT_SPACE);
  set_status (op, OP_PREFIX, REMOVE_CURRENT_SPACE);
  set_status (op, OP_BIG, REMOVE_CURRENT_SPACE);
}

static inline void init_expect_after (int op) {
  set_status (op, OP_TEXT, REMOVE_CURRENT_SPACE);
  set_status (op, OP_BINARY, REMOVE_SPACE_BEFORE);
  set_status (op, OP_POSTFIX, REMOVE_CURRENT_SPACE);
  set_status (op, OP_INFIX, REMOVE_CURRENT_SPACE);
  set_status (op, OP_APPLY, REMOVE_SPACE_BEFORE);
  set_status (op, OP_SEPARATOR, REMOVE_SPACE_BEFORE);
  set_status (op, OP_MIDDLE_BRACKET, REMOVE_SPACE_BEFORE);
  set_status (op, OP_CLOSING_BRACKET, REMOVE_SPACE_BEFORE);
}

static inline void init_expect_space (int op) {
  set_status (op, OP_TEXT, REMOVE_CURRENT_SPACE);
  set_status (op, OP_SYMBOL, REMOVE_SPACE_BEFORE);
  set_status (op, OP_UNARY, REMOVE_SPACE_BEFORE);
  set_status (op, OP_BINARY, REMOVE_SPACE_BEFORE);
  set_status (op, OP_N_ARY, REMOVE_SPACE_BEFORE);
  set_status (op, OP_PREFIX, REMOVE_SPACE_BEFORE);
  set_status (op, OP_POSTFIX, REMOVE_SPACE_BEFORE);
  set_status (op, OP_INFIX, REMOVE_SPACE_BEFORE);
  set_status (op, OP_SEPARATOR, REMOVE_SPACE_BEFORE);
  set_status (op, OP_MIDDLE_BRACKET, REMOVE_SPACE_BEFORE);
  set_status (op, OP_CLOSING_BRACKET, REMOVE_SPACE_BEFORE);
  set_status (op, OP_BIG, REMOVE_SPACE_BEFORE);
}

void
init_succession_status_table () {
  for (int i=0; i < (OP_TOTAL * OP_TOTAL); i++)
    succession_status_table[i]= SUCCESSION_OK;

  for (int i=0; i<OP_TOTAL; i++) {
    set_status (OP_UNKNOWN, i, REMOVE_ALL_SPACE);
    set_status (i, OP_UNKNOWN, REMOVE_ALL_SPACE);
  }

  init_expect_after (OP_TEXT);
  init_could_end    (OP_SYMBOL);
  init_expect_space (OP_UNARY);
  init_expect_space (OP_BINARY);
  init_expect_space (OP_N_ARY);
  init_expect_after (OP_PREFIX);
  init_could_end    (OP_POSTFIX);
  init_expect_after (OP_INFIX);
  init_expect_after (OP_APPLY);
  init_expect_after (OP_SEPARATOR);
  init_expect_after (OP_OPENING_BRACKET);
  init_expect_after (OP_MIDDLE_BRACKET);
  init_could_end    (OP_CLOSING_BRACKET);
  init_expect_after (OP_BIG);
  set_status (OP_APPLY, OP_BINARY, SUCCESSION_OK);
  set_status (OP_OPENING_BRACKET, OP_CLOSING_BRACKET, SUCCESSION_OK);
}

/******************************************************************************
* Default group of a string
******************************************************************************/

language_rep::language_rep (string s):
  rep<language> (s), lan_name (s), hl_lan (0) {}

string
language_rep::get_group (string s) {
  (void) s;
  return "default";
}

array<string>
language_rep::get_members (string s) {
  (void) s;
  return array<string> ();
}

void
language_rep::highlight (tree t) {
  if (hl_lan != 0 && !has_highlight (t, hl_lan))
    packrat_highlight (res_name, "Main", t);
}

string
language_rep::get_color (tree t, int start, int end) {
  (void) t; (void) start; (void) end;
  return "";
}

/******************************************************************************
 * Encode and decode colors for syntax highlighting
 ******************************************************************************/

hashmap<string,int>
language_rep::color_encoding(type_helper<int>::init, 32);

void
initialize_color_encodings () {
  language_rep::color_encoding ("comment")= 1;
  language_rep::color_encoding ("error")= 3;
  language_rep::color_encoding ("preprocessor")= 4;
  language_rep::color_encoding ("preprocessor_directive")= 5;
  language_rep::color_encoding ("constant")= 10;
  language_rep::color_encoding ("constant_identifier")= 11;
  language_rep::color_encoding ("constant_function")= 12;
  language_rep::color_encoding ("constant_type")= 13;
  language_rep::color_encoding ("constant_category")= 14;
  language_rep::color_encoding ("constant_module")= 15;
  language_rep::color_encoding ("constant_number")= 16;
  language_rep::color_encoding ("constant_string")= 17;
  language_rep::color_encoding ("constant_char")= 18;
  language_rep::color_encoding ("variable")= 20;
  language_rep::color_encoding ("variable_identifier")= 21;
  language_rep::color_encoding ("variable_function")= 22;
  language_rep::color_encoding ("variable_type")= 23;
  language_rep::color_encoding ("variable_category")= 24;
  language_rep::color_encoding ("variable_module")= 25;
  language_rep::color_encoding ("variable_ioarg")= 26;
  language_rep::color_encoding ("declare")= 30;
  language_rep::color_encoding ("declare_identifier")= 31;
  language_rep::color_encoding ("declare_function")= 32;
  language_rep::color_encoding ("declare_type")= 33;
  language_rep::color_encoding ("declare_category")= 34;
  language_rep::color_encoding ("declare_module")= 35;
  language_rep::color_encoding ("operator")= 40;
  language_rep::color_encoding ("operator_openclose")= 41;
  language_rep::color_encoding ("operator_field")= 42;
  language_rep::color_encoding ("operator_special")= 43;
  language_rep::color_encoding ("keyword")= 50;
  language_rep::color_encoding ("keyword_conditional")= 51;
  language_rep::color_encoding ("keyword_control")= 52;
}

void
initialize_color_decodings (string lan_name) {
  language lan= prog_language(lan_name);
  string pfx= "syntax:" * lan->lan_name * ":";
  lan->color_decoding (-1)= get_preference (pfx * "none", "red");
  lan->color_decoding (1) = get_preference (pfx * "comment", "brown");
  lan->color_decoding (3) = get_preference (pfx * "error", "dark red");
  lan->color_decoding (4) = get_preference (pfx * "preprocessor", "#004000");
  lan->color_decoding (5) = get_preference (pfx * "preprocessor_directive", "#20a000");
  lan->color_decoding (10)= get_preference (pfx * "constant", "#4040c0");
  lan->color_decoding (11)= get_preference (pfx * "constant_identifier", "#4040c0");
  lan->color_decoding (12)= get_preference (pfx * "constant_function", "#4040c0");
  lan->color_decoding (13)= get_preference (pfx * "constant_type", "#4040c0");
  lan->color_decoding (14)= get_preference (pfx * "constant_category", "#4040c0");
  lan->color_decoding (15)= get_preference (pfx * "constant_module", "#4040c0");
  lan->color_decoding (16)= get_preference (pfx * "constant_number", "#3030b0");
  lan->color_decoding (17)= get_preference (pfx * "constant_string", "dark grey");
  lan->color_decoding (18)= get_preference (pfx * "constant_char", "#333333");
  lan->color_decoding (20)= get_preference (pfx * "variable", "#606060");
  lan->color_decoding (21)= get_preference (pfx * "variable_identifier", "#204080");
  lan->color_decoding (22)= get_preference (pfx * "variable_function", "#606060");
  lan->color_decoding (23)= get_preference (pfx * "variable_type", "#00c000");
  lan->color_decoding (24)= get_preference (pfx * "variable_category", "#00c000");
  lan->color_decoding (25)= get_preference (pfx * "variable_module", "#00c000");
  lan->color_decoding (26)= get_preference (pfx * "variable_ioarg", "#00b000");
  lan->color_decoding (30)= get_preference (pfx * "declare", "#0000c0");
  lan->color_decoding (31)= get_preference (pfx * "declare_identifier", "#0000c0");
  lan->color_decoding (32)= get_preference (pfx * "declare_function", "#0000c0");
  lan->color_decoding (33)= get_preference (pfx * "declare_type", "#0000c0");
  lan->color_decoding (34)= get_preference (pfx * "declare_category", "#d030d0");
  lan->color_decoding (35)= get_preference (pfx * "declare_module", "#0000c0");
  lan->color_decoding (40)= get_preference (pfx * "operator", "#8b008b");
  lan->color_decoding (41)= get_preference (pfx * "operator_openclose", "#B02020");
  lan->color_decoding (42)= get_preference (pfx * "operator_field", "#888888");
  lan->color_decoding (43)= get_preference (pfx * "operator_special", "orange");
  lan->color_decoding (50)= get_preference (pfx * "keyword", "#309090");
  lan->color_decoding (51)= get_preference (pfx * "keyword_conditional", "#309090");
  lan->color_decoding (52)= get_preference (pfx * "keyword_control", "#000080");
}

int
encode_color (string s) {
  if (N(language_rep::color_encoding) == 0) initialize_color_encodings ();
  if (language_rep::color_encoding->contains (s))
    return language_rep::color_encoding[s];
  else return -1;
}

string
decode_color (string lan_name, int c) {
  language lan= prog_language (lan_name);
  if (N(lan->color_decoding) == 0) initialize_color_decodings (lan_name);
  if (lan->color_decoding->contains (c)) return lan->color_decoding[c];
  else return "";
}
