//*****************************************************************************
// MODULE     : init-texmacs-atoms.sce
// DESCRIPTION: Overload Scilab display routines in order to return Scheme
//              trees to TeXmacs.
// COPYRIGHT  : (C) 2013 François Poulain, Joris van der Hoeven
//*****************************************************************************
// This software falls under the GNU general public license version 3 or later.
// It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
// in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
//*****************************************************************************

funcprot(0)
texmacs_path= getenv("TEXMACS_PATH");
exec (fullfile (getenv("TEXMACS_PATH"), 'plugins/scilab/bin/tmstree.sci'), -1);
exec (fullfile (getenv("TEXMACS_PATH"), 'plugins/scilab/bin/plotout.sci'), -1);
exec (fullfile (getenv("TEXMACS_PATH"), 'plugins/scilab/bin/add_to_insert_menu.sci'), -1);

function tmsend (msg)
  DATA_BEGIN= ascii (2);
  DATA_END= ascii (5);
  msg= strsubst (msg, '%', '%%');
  mprintf (DATA_BEGIN + msg + DATA_END);
endfunction

function tmout(v)
  out= tmstree(v);
  out= makeStreeNode ("with", ["mode" "math" out]);
  out= makeStreeNode ("document", [out ""])
  tmsend (out);
endfunction

function tmcmd (msg)
  if part (msg, 1:8) == "scheme: " then
    msg= (part (msg, 9:length(msg)));
  end
  msg= "command: " + msg;
  tmsend (msg);
endfunction

char_codes= ["s" "p" "b" "sp" "spb" "msp" "i" "c" "h" "fptr" "mc" "l" "hm" ..
             "ptr" "ce" "st" "r" "lss" "ip"]

for i= 1:size (char_codes, '*') do
  deff('[]=%' + char_codes (i) + '_p(a)', "tmout (a)");
end

funcprot(1)

function lst= scilab_lst_all (libr)
  lst= [];
  if argn (2) == 0 then
    libr= getvariablesonstack ();
  elseif size (libr, '*') == 1 & exists (libr) & type (eval (libr)) == 14 then
    lst= libraryinfo (libr);
    return;
  end
  for i= 1:size(libr, '*') do
    if exists (libr(i)) & type (eval (libr(i))) == 14 then
      lst= [lst;(scilab_lst_all (libr(i)))];
    else
      lst= [lst;libr(i)];
    end
  end
endfunction

function scilab_complete (str, pos)
  lst= scilab_lst_all ();
  lst= lst (grep (lst, '/^'+str+'/', 'r'));
  for i= 1:size(lst, '*') do
    lst(i)= part (lst(i), (pos+1):length(lst(i)));
  end
  lst= strsubst (lst, '%', '%%');
  tmsend (make ("tuple", [str;lst]'));
endfunction

banner
