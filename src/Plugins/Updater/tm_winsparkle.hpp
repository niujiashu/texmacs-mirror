/******************************************************************************
 * MODULE     : tm_winsparkle.hpp
 * DESCRIPTION: Manager class for the autoupdater WinSparkle framework
 * COPYRIGHT  : (C) 2013 Miguel de Benito Delgado
 *******************************************************************************
 * This software falls under the GNU general public license version 3 or later.
 * It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
 * in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
 ******************************************************************************/

#include "tm_updater.hpp"

class tm_winsparkle : public tm_updater
{
  bool running;
  
  tm_winsparkle (url _appcast_url);
  ~tm_winsparkle ();
  friend class tm_updater;

public:
  bool isRunning () const { return running; }
  bool checkInBackground ();
  bool checkInForeground ();
};