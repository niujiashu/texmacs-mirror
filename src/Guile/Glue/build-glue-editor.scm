
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; MODULE      : build-glue-basic.scm
;; DESCRIPTION : Building basic glue for the editor
;; COPYRIGHT   : (C) 1999  Joris van der Hoeven
;;
;; This software falls under the GNU general public licence and comes WITHOUT
;; ANY WARRENTY WHATSOEVER. See the file $TEXMACS_PATH/LICENCE for details.
;; If you don't have this file, write to the Free Software Foundation, Inc.,
;; 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(output-copyright "build-glue-editor.scm")

(build
  "get_server()->get_editor()->"
  "initialize_glue_editor"

  (key-press key_press (void string))
  (emulate-keyboard emulate_keyboard (void string))
  (emulate-keyboard-message emulate_keyboard (void string string))
  (complete-try? complete_try (bool))
  
  (go-left go_left (void))
  (go-right go_right (void))
  (go-up go_up (void))
  (go-down go_down (void))
  (go-start go_start (void))
  (go-end go_end (void))
  (go-start-of go_start_of (void string))
  (go-end-of go_end_of (void string))
  (go-start-with go_start_with (void string string))
  (go-end-with go_end_with (void string string))
  (go-start-line go_start_line (void))
  (go-end-line go_end_line (void))
  (go-page-up go_page_up (void))
  (go-page-down go_page_down (void))
  (go-to-label go_to_label (void string))

  (select-all select_all (void))
  (select-line select_line (void))
  (select-from-cursor select_from_cursor (void))
  (select-from-keyboard select_from_keyboard (void bool))
  (select-from-shift-keyboard select_from_shift_keyboard (void))
  (select-enlarge select_enlarge (void))
  (select-enlarge-environmental select_enlarge_environmental (void))
  (selection-active-any? selection_active_any (bool))
  (selection-active-normal? selection_active_normal (bool))
  (selection-active-table? selection_active_table (bool))
  (selection-active-small? selection_active_small (bool))
  (selection-active-enlarging? selection_active_enlarging (bool))
  (selection-set-start selection_set_start (void))
  (selection-set-end selection_set_end (void))
  (clipboard-copy selection_copy (void string))
  (clipboard-cut selection_cut (void string))
  (clipboard-cut-at cut (void path))
  (clipboard-paste selection_paste (void string))
  (selection-move selection_move (void))
  (clipboard-clear selection_clear (void string))
  (selection-cancel selection_cancel (void))
  (clipboard-set-import selection_set_import (void string))
  (clipboard-set-export selection_set_export (void string))
  (clipboard-get-import selection_get_import (string))
  (clipboard-get-export selection_get_export (string))
  (undo undo (void))
  (redo redo (void))

  (in-normal-mode? in_normal_mode (bool))
  (in-search-mode? in_search_mode (bool))
  (in-replace-mode? in_replace_mode (bool))
  (in-spell-mode? in_spell_mode (bool))
  (inside? inside (bool string))
  (inside-with? inside_with (bool string string))
  (inside-which inside_which (string scheme_tree))
  (search-upwards search_upwards (path string))
  (search-upwards-in-set search_upwards_in_set (path scheme_tree))
  (search-start search_start (void bool))
  (search-button-next search_button_next (void))
  (replace-start replace_start (void string string bool))
  (spell-start spell_start (void))
  (spell-replace spell_replace (void string))

  (insert-string insert_tree (void string))
  (insert-tree insert_tree (void texmacs_tree))
  (insert-tree-go-to insert_tree (void texmacs_tree path))
  (insert-return insert_return (void))
  (remove-backwards remove_backwards (void))
  (remove-forwards remove_forwards (void))
  (remove-structure-backwards remove_structure_backwards (void))
  (remove-structure-forwards remove_structure_forwards (void))
  (remove-structure-upwards remove_structure_upwards (void))
  (make-format make_format (void string))
  (make-htab make_htab (void string))
  (make-space make_space (void string))
  (make-var-space make_space (void string string string))
  (make-hspace make_hspace (void string))
  (make-var-hspace make_hspace (void string string string))
  (make-vspace-before make_vspace_before (void string))
  (make-var-vspace-before make_vspace_before
    (void string string string))
  (make-vspace-after make_vspace_after (void string))
  (make-var-vspace-after make_vspace_after (void string string string))
  (make-move make_move (void string string))
  (make-resize make_resize (void string string string string))
  (make-insertion make_insertion (void string))
  (position-insertion position_insertion (void string bool))
  (make-postscript make_postscript
    (void string bool string string string string string string))

  (make-group make_group (void))
  (make-lprime make_lprime (void string))
  (make-rprime make_rprime (void string))
  (make-below make_below (void))
  (make-above make_above (void))
  (make-script make_script (void bool bool))
  (make-fraction make_fraction (void))
  (make-sqrt make_sqrt (void))
  (make-wide make_wide (void string))
  (make-wide-under make_wide_under (void string))
  (make-var-sqrt make_var_sqrt (void))
  (make-neg make_neg (void))
  (make-tree make_tree (void))
  (inside-tree? inside_tree (bool))
  (branch-insert branch_insert (void bool))
  (branch-delete branch_delete (void))

  (make-sub-table make_sub_table (void))
  (table-disactivate table_disactivate (void))
  (table-extract-format table_extract_format (void))
  (table-insert-row table_insert_row (void bool))
  (table-insert-column table_insert_column (void bool))
  (table-delete-row table_delete_row (void bool))
  (table-delete-column table_delete_column (void bool))
  (table-nr-rows table_nr_rows (int))
  (table-nr-columns table_nr_columns (int))
  (table-which-row table_which_row (int))
  (table-which-column table_which_column (int))
  (table-search-cell table_search_cell (path int int))
  (table-go-to table_go_to (void int int))
  (table-set-format table_set_format (void string string))
  (table-get-format table_get_format (string string))
  (table-del-format table_del_format (void string))
  (table-row-decoration table_row_decoration (void bool))
  (table-column-decoration table_column_decoration (void bool))
  (table-format-center table_format_center (void))
  (set-cell-mode set_cell_mode (void string))
  (get-cell-mode get_cell_mode (string))
  (cell-set-format cell_set_format (void string string))
  (cell-get-format cell_get_format (string string))
  (cell-del-format cell_del_format (void string))
  (cell-multi-paragraph cell_multi_paragraph (void bool))
  (cell-multi-paragraph? cell_is_multi_paragraph (bool))
  (table-test table_test (void))

  (init-default-one init_default (void string))
  (init-env init_env (void string string))
  (init-env-tree init_env (void string texmacs_tree))
  (init-style init_style (void string))
  (init-extra-style init_extra_style (void string))
  (get-env get_env_string (string string))
  (get-env-tree get_env_value (texmacs_tree string))
  (get-init-tree get_init_value (texmacs_tree string))
  (context-has? defined_at_cursor (bool string))
  (style-has? defined_at_init (bool string))
  (init-has? defined_in_init (bool string))
  (in-preamble-mode? in_preamble_mode (bool))
  (menu-before-action before_menu_action (void))
  (menu-after-action after_menu_action (void))
  (is-deactivated? is_deactivated (bool))
  (activate activate (void))
  (make-active make_active (void string int))
  (make-deactivated make_deactivated (void string int string))
  (make-deactivated-arg make_deactivated (void string int string string))
  (insert-argument insert_argument (void))
  (make-return-before make_return_before (void))
  (make-return-after make_return_after (bool))
  (make-assign make_assign (void string string))
  (make-with make_with (void string string))
  (make-big-expand make_big_expand (void string))
  (make-expand make_expand (void string))
  (make-expand-arity make_expand (void string int))
  (temp-proof-fix temp_proof_fix (void))
  (make-apply make_apply (void string))

  (view-set-property set_property (void scheme_tree scheme_tree))
  (view-get-property get_property (scheme_tree scheme_tree))
  (clear-buffer clear_buffer (void))
  (tex-buffer tex_buffer (void))
  (clear-local-info clear_local_info (void))
  (update-buffer typeset_invalidate_all (void))
  (generate-all-aux generate_aux (void))
  (generate-aux generate_aux (void string))
  (set-page-parameters set_page_parameters (void))
  (set-page-medium set_page_medium (void string))
  (set-page-type set_page_type (void string))
  (set-page-orientation set_page_orientation (void string))
  (print-to-file print_to_file (void url))
  (print-pages-to-file print_to_file (void url string string))
  (print print_buffer (void))
  (print-pages print_buffer (void string string))
  (export-postscript export_ps (void url))
  (export-pages-postscript export_ps (void url string string))
  (set-message set_message (void string string))

  (footer-eval footer_eval (void string))
  (the-line the_line (texmacs_tree))
  (the-selection selection_get (texmacs_tree))
  (the-buffer the_buffer (texmacs_tree))
  (the-path the_path (path))
  (process-input process_input (void))
  (make-session make_session (void string string))
  (start-input start_input (void))
  (start-output start_output (void))
  (session-use-math-input session_use_math_input (void bool))
  (session-math-input? session_is_using_math_input (bool))
  (session-go-up session_go_up (void))
  (session-go-down session_go_down (void))
  (session-go-left session_go_left (void))
  (session-go-right session_go_right (void))
  (session-go-page-up session_go_page_up (void))
  (session-go-page-down session_go_page_down (void))
  (session-remove-backwards session_remove_backwards (void))
  (session-remove-forwards session_remove_forwards (void))
  (session-insert-text-field session_insert_text_field (void))
  (session-insert-input-above session_insert_input_above (void))
  (session-insert-input-below session_insert_input_below (void))
  (session-fold-input session_fold_input (void))
  (session-remove-input-backwards session_remove_input_backwards (void))
  (session-remove-input-forwards session_remove_input_forwards (void))
  (session-remove-all-outputs session_remove_all_outputs (void))
  (session-remove-previous-output session_remove_previous_output (void))
  (session-split session_split (void))
  (session-complete-try? session_complete_try (bool))
  (interactive interactive (void scheme_tree scheme_tree))
  (connection-busy? busy_connection (bool))
  (connection-interrupt interrupt_connection (void))
  (connection-stop stop_connection (void))

  (show-tree show_tree (void))
  (show-env show_env (void))
  (show-path show_path (void))
  (show-cursor show_cursor (void))
  (show-selection show_selection (void))
  (show-keymaps show_keymaps (void))
  (show-meminfo show_meminfo (void))
  (edit-special edit_special (void))
  (edit-test edit_test (void))

  (length-decode decode_length (int string))
  (length-add add_lengths (string string string))
  (length-mult multiply_length (string double string))
  (length? is_length (bool string))
  (length-divide divide_lengths (double string string))

  (tm-assign assign (void path texmacs_tree))
  (tm-insert insert (void path texmacs_tree))
  (tm-remove remove (void path int))
  (tm-split split (void path))
  (tm-join join (void path))
  (tm-ins-unary ins_unary (void path tree_label))
  (tm-rem-unary rem_unary (void path))
  (tm-correct correct (void path))
  (tm-where current_position (path))
  (tm-go-to go_to (void path))
  (tm-go-to-start go_to_start (void path))
  (tm-go-to-end go_to_end (void path))

  (tm-position-new position_new (int))
  (tm-position-delete position_delete (void int))
  (tm-position-set position_set (void int path))
  (tm-position-get position_get (path int)))
