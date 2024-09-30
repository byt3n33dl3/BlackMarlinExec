
/***************************************************************************
 * timing.cc -- Functions related to computing crack timing and keeping    *
 * track of rates.                                                         *
 *                                                                         *
 ***********************IMPORTANT NMAP LICENSE TERMS************************
 *                                                                         *
 * The Nmap Security Scanner is (C) 1996-2019 Insecure.Com LLC ("The Nmap  *
 * Project"). Nmap is also a registered trademark of the Nmap Project.     *
 * This program is free software; you may redistribute and/or modify it    *
 * under the terms of the GNU General Public License as published by the   *
 * Free Software Foundation; Version 2 ("GPL"), BUT ONLY WITH ALL OF THE   *
 * CLARIFICATIONS AND EXCEPTIONS DESCRIBED HEREIN.  This guarantees your   *
 * right to use, modify, and redistribute this software under certain      *
 * conditions.  If you wish to embed Nmap technology into proprietary      *
 * software, we sell alternative licenses (contact sales@nmap.com).        *
 * Dozens of software vendors already license Nmap technology such as      *
 * host discovery, port scanning, OS detection, version detection, and     *
 * the Nmap Scripting Engine.                                              *
 *                                                                         *
 * Note that the GPL places important restrictions on "derivative works",  *
 * yet it does not provide a detailed definition of that term.  To avoid   *
 * misunderstandings, we interpret that term as broadly as copyright law   *
 * allows.  For example, we consider an application to constitute a        *
 * derivative work for the purpose of this license if it does any of the   *
 * following with any software or content covered by this license          *
 * ("Covered Software"):                                                   *
 *                                                                         *
 * o Integrates source code from Covered Software.                         *
 *                                                                         *
 * o Reads or includes copyrighted data files, such as Nmap's nmap-os-db   *
 * or nmap-service-probes.                                                 *
 *                                                                         *
 * o Is designed specifically to execute Covered Software and parse the    *
 * results (as opposed to typical shell or execution-menu apps, which will *
 * execute anything you tell them to).                                     *
 *                                                                         *
 * o Includes Covered Software in a proprietary executable installer.  The *
 * installers produced by InstallShield are an example of this.  Including *
 * Nmap with other software in compressed or archival form does not        *
 * trigger this provision, provided appropriate open source decompression  *
 * or de-archiving software is widely available for no charge.  For the    *
 * purposes of this license, an installer is considered to include Covered *
 * Software even if it actually retrieves a copy of Covered Software from  *
 * another source during runtime (such as by downloading it from the       *
 * Internet).                                                              *
 *                                                                         *
 * o Links (statically or dynamically) to a library which does any of the  *
 * above.                                                                  *
 *                                                                         *
 * o Executes a helper program, module, or script to do any of the above.  *
 *                                                                         *
 * This list is not exclusive, but is meant to clarify our interpretation  *
 * of derived works with some common examples.  Other people may interpret *
 * the plain GPL differently, so we consider this a special exception to   *
 * the GPL that we apply to Covered Software.  Works which meet any of     *
 * these conditions must conform to all of the terms of this license,      *
 * particularly including the GPL Section 3 requirements of providing      *
 * source code and allowing free redistribution of the work as a whole.    *
 *                                                                         *
 * As another special exception to the GPL terms, the Nmap Project grants  *
 * permission to link the code of this program with any version of the     *
 * OpenSSL library which is distributed under a license identical to that  *
 * listed in the included docs/licenses/OpenSSL.txt file, and distribute   *
 * linked combinations including the two.                                  *
 *                                                                         *
 * The Nmap Project has permission to redistribute Npcap, a packet         *
 * capturing driver and library for the Microsoft Windows platform.        *
 * Npcap is a separate work with it's own license rather than this Nmap    *
 * license.  Since the Npcap license does not permit redistribution        *
 * without special permission, our Nmap Windows binary packages which      *
 * contain Npcap may not be redistributed without special permission.      *
 *                                                                         *
 * Any redistribution of Covered Software, including any derived works,    *
 * must obey and carry forward all of the terms of this license, including *
 * obeying all GPL rules and restrictions.  For example, source code of    *
 * the whole work must be provided and free redistribution must be         *
 * allowed.  All GPL references to "this License", are to be treated as    *
 * including the terms and conditions of this license text as well.        *
 *                                                                         *
 * Because this license imposes special exceptions to the GPL, Covered     *
 * Work may not be combined (even as part of a larger work) with plain GPL *
 * software.  The terms, conditions, and exceptions of this license must   *
 * be included as well.  This license is incompatible with some other open *
 * source licenses as well.  In some cases we can relicense portions of    *
 * Nmap or grant special permissions to use it in other open source        *
 * software.  Please contact fyodor@nmap.org with any such requests.       *
 * Similarly, we don't incorporate incompatible open source software into  *
 * Covered Software without special permission from the copyright holders. *
 *                                                                         *
 * If you have any questions about the licensing restrictions on using     *
 * Nmap in other works, we are happy to help.  As mentioned above, we also *
 * offer an alternative license to integrate Nmap into proprietary         *
 * applications and appliances.  These contracts have been sold to dozens  *
 * of software vendors, and generally include a perpetual license as well  *
 * as providing support and updates.  They also fund the continued         *
 * development of Nmap.  Please email sales@nmap.com for further           *
 * information.                                                            *
 *                                                                         *
 * If you have received a written license agreement or contract for        *
 * Covered Software stating terms other than these, you may choose to use  *
 * and redistribute Covered Software under those terms instead of these.   *
 *                                                                         *
 * Source is provided to this software because we believe users have a     *
 * right to know exactly what a program is going to do before they run it. *
 * This also allows you to audit the software for security holes.          *
 *                                                                         *
 * Source code also allows you to port Nmap to new platforms, fix bugs,    *
 * and add new features.  You are highly encouraged to send your changes   *
 * to the dev@nmap.org mailing list for possible incorporation into the    *
 * main distribution.  By sending these changes to Fyodor or one of the    *
 * Insecure.Org development mailing lists, or checking them into the Nmap  *
 * source code repository, it is understood (unless you specify            *
 * otherwise) that you are offering the Nmap Project the unlimited,        *
 * non-exclusive right to reuse, modify, and relicense the code.  Nmap     *
 * will always be available Open Source, but this is important because     *
 * the inability to relicense code has caused devastating problems for     *
 * other Free Software projects (such as KDE and NASM).  We also           *
 * occasionally relicense the code to third parties as discussed above.    *
 * If you wish to specify special license conditions of your               *
 * contributions, just say so when you send them.                          *
 *                                                                         *
 * This program is distributed in the hope that it will be useful, but     *
 * WITHOUT ANY WARRANTY; without even the implied warranty of              *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the Nmap      *
 * license file for more details (it's in a COPYING file included with     *
 * Nmap, and also available from https://svn.nmap.org/nmap/COPYING)        *
 *                                                                         *
 ***************************************************************************/

/* $Id: timing.cc 12955 2009-04-15 00:37:03Z fyodor $ */

#include "timing.h"
#include "NcrackOps.h"
#include "utils.h"
#include "time.h"

extern NcrackOps o;


/* current_rate_history defines how far back (in seconds) we look when
   calculating the current rate. */
RateMeter::RateMeter(double current_rate_history) {
  this->current_rate_history = current_rate_history;
  start_tv.tv_sec = 0;
  start_tv.tv_usec = 0;
  stop_tv.tv_sec = 0;
  stop_tv.tv_usec = 0;
  last_update_tv.tv_sec = 0;
  last_update_tv.tv_usec = 0;
  total = 0.0;
  current_rate = 0.0;
  assert(!isSet(&start_tv));
  assert(!isSet(&stop_tv));
}

void RateMeter::start(const struct timeval *now) {
  assert(!isSet(&start_tv));
  assert(!isSet(&stop_tv));
  if (now == NULL)
    gettimeofday(&start_tv, NULL);
  else
    start_tv = *now;
}

void RateMeter::stop(const struct timeval *now) {
  assert(isSet(&start_tv));
  assert(!isSet(&stop_tv));
  if (now == NULL)
    gettimeofday(&stop_tv, NULL);
  else
    stop_tv = *now;
}

/* Update the rates to reflect the given amount added to the total at the time
   now. If now is NULL, get the current time with gettimeofday. */
void RateMeter::update(double amount, const struct timeval *now) {
  struct timeval tv;
  double diff;
  double interval;
  double count;

  assert(isSet(&start_tv));
  assert(!isSet(&stop_tv));

  /* Update the total. */
  total += amount;

  if (now == NULL) {
    gettimeofday(&tv, NULL);
    now = &tv;
  }
  if (!isSet(&last_update_tv))
    last_update_tv = start_tv;

  /* Calculate the approximate moving average of how much was recorded in the
     last current_rate_history seconds. This average is what is returned as the
     "current" rate. */

  /* How long since the last update? */
  diff = TIMEVAL_SUBTRACT(*now, last_update_tv) / 1000000.0;

  if (diff < -current_rate_history)
    /* This happened farther in the past than we care about. */
    return;

  if (diff < 0.0) {
    /* If the event happened in the past, just add it into the total and don't
       change last_update_tv, as if it had happened at the same time as the most
       recent event. */
    now = &last_update_tv;
    diff = 0.0;
  }

  /* Find out how far back in time to look. We want to look back
     current_rate_history seconds, or to when the last update occurred,
     whichever is longer. However, we never look past the start. */
  struct timeval tmp;
  /* Find the time current_rate_history seconds after the start. That's our
     threshold for deciding how far back to look. */
  TIMEVAL_ADD(tmp, start_tv, (time_t) (current_rate_history * 1000000.0));
  if (TIMEVAL_AFTER(*now, tmp))
    interval = MAX(current_rate_history, diff);
  else
    interval = TIMEVAL_SUBTRACT(*now, start_tv) / 1000000.0;
  assert(diff <= interval);
  /* If we record an amount in the very same instant that the timer is started,
     there's no way to calculate meaningful rates. Ignore it. */
  if (interval == 0.0)
    return;

  /* To calculate the approximate average of the rate over the last
     interval seconds, we assume that the rate was constant over that interval.
     We calculate how much would have been received in that interval, ignoring
     the first diff seconds' worth:
       (interval - diff) * current_rate.
     Then we add how much was received in the most recent diff seconds. Divide
     by the width of the interval to get the average. */
  count = (interval - diff) * current_rate + amount;
  current_rate = count / interval;

  last_update_tv = *now;
}

double RateMeter::getOverallRate(const struct timeval *now) const {
  double elapsed;

  elapsed = elapsedTime(now);
  if (elapsed <= 0.0)
    return 0.0;
  else
    return total / elapsed;
}

/* Get the "current" rate (actually a moving average of the last
   current_rate_history seconds). If update is true (its default value), lower
   the rate to account for the time since the last record. */
double RateMeter::getCurrentRate(const struct timeval *now, bool update) {
  if (update)
    this->update(0.0, now);

  return current_rate;
}

double RateMeter::getTotal(void) const {
  return total;
}

/* Get the number of seconds the meter has been running: if it has been stopped,
   the amount of time between start and stop, or if it is still running, the
   amount of time between start and now. */
double RateMeter::elapsedTime(const struct timeval *now) const {
  struct timeval tv;
  const struct timeval *end_tv;

  assert(isSet(&start_tv));

  if (isSet(&stop_tv)) {
    end_tv = &stop_tv;
  } else if (now == NULL) {
    gettimeofday(&tv, NULL);
    end_tv = &tv;
  } else {
    end_tv = now;
  }

  return TIMEVAL_SUBTRACT(*end_tv, start_tv) / 1000000.0;
}

/* Returns true if tv has been initialized; i.e., its members are not all
   zero. */
bool RateMeter::isSet(const struct timeval *tv) {
  return tv->tv_sec != 0 || tv->tv_usec != 0;
}

PacketRateMeter::PacketRateMeter(double current_rate_history) {
  packet_rate_meter = RateMeter(current_rate_history);
  byte_rate_meter = RateMeter(current_rate_history);
}

void PacketRateMeter::start(const struct timeval *now) {
  packet_rate_meter.start(now);
  byte_rate_meter.start(now);
}

void PacketRateMeter::stop(const struct timeval *now) {
  packet_rate_meter.stop(now);
  byte_rate_meter.stop(now);
}

/* Record one packet of length len. */
void PacketRateMeter::update(u32 len, const struct timeval *now) {
  packet_rate_meter.update(1, now);
  byte_rate_meter.update(len, now);
}

double PacketRateMeter::getOverallPacketRate(const struct timeval *now) const {
  return packet_rate_meter.getOverallRate(now);
}

double PacketRateMeter::getCurrentPacketRate(const struct timeval *now,
    bool update) {
  return packet_rate_meter.getCurrentRate(now, update);
}

double PacketRateMeter::getOverallByteRate(const struct timeval *now) const {
  return byte_rate_meter.getOverallRate(now);
}

double PacketRateMeter::getCurrentByteRate(const struct timeval *now,
    bool update) {
  return byte_rate_meter.getCurrentRate(now, update);
}

unsigned long long PacketRateMeter::getNumPackets(void) const {
  return (unsigned long long) packet_rate_meter.getTotal();
}

unsigned long long PacketRateMeter::getNumBytes(void) const {
  return (unsigned long long) byte_rate_meter.getTotal();
}

ScanProgressMeter::ScanProgressMeter()
{
  gettimeofday(&begin, NULL);
  last_print_test = begin;
  memset(&last_print, 0, sizeof(last_print));
  memset(&last_est, 0, sizeof(last_est));
  beginOrEndTask(&begin, NULL, true);
}

ScanProgressMeter::~ScanProgressMeter() {
  ;
}

/* Decides whether a timing report is likely to even be
   printed.  There are stringent limitations on how often they are
   printed, as well as the verbosity level that must exist.  So you
   might as well check this before spending much time computing
   progress info.  now can be NULL if caller doesn't have the current
   time handy.  Just because this function returns true does not mean
   that the next printStatsIfNecessary will always print something.
   It depends on whether time estimates have changed, which this func
   doesn't even know about. */
bool ScanProgressMeter::mayBePrinted(const struct timeval *now) {
  struct timeval tv;

  if (!o.verbose)
    return false;

  if (!now) {
    gettimeofday(&tv, NULL);
    now = (const struct timeval *) &tv;
  }

  if (last_print.tv_sec == 0) {
    /* We've never printed before -- the rules are less stringent */
    if (difftime(now->tv_sec, begin.tv_sec) > 30)
      return true;
    else
      return false;
  } 

  if (difftime(now->tv_sec, last_print_test.tv_sec) < 3)
    return false;  /* No point even checking too often */

  /* We'd never want to print more than once per 30 seconds */
  if (difftime(now->tv_sec, last_print.tv_sec) < 30)
    return false;

  return true;
}

/* Return an estimate of the time remaining if a process was started at begin
   and is perc_done of the way finished. Returns inf if perc_done == 0.0. */
static double estimate_time_left(double perc_done,
                                 const struct timeval *begin,
                                 const struct timeval *now) {
  double time_used_s;
  double time_needed_s;

  time_used_s = difftime(now->tv_sec, begin->tv_sec);
  time_needed_s = time_used_s / perc_done;

  return time_needed_s - time_used_s;
}

/* Prints an estimate of when this scan will complete.  It only does
   so if mayBePrinted() is true, and it seems reasonable to do so
   because the estimate has changed significantly.  Returns whether
   or not a line was printed.*/
bool ScanProgressMeter::printStatsIfNecessary(double perc_done, 
					       const struct timeval *now) {
  struct timeval tvtmp;
  double time_left_s;
  bool printit = false;

  if (!now) {
    gettimeofday(&tvtmp, NULL);
    now = (const struct timeval *) &tvtmp;
  }

  if (!mayBePrinted(now))
    return false;

  last_print_test = *now;

  if (perc_done <= 0.003)
    return false; /* Need more info first */

  assert(perc_done <= 1.0);

  time_left_s = estimate_time_left(perc_done, &begin, now);

  if (time_left_s < 30)
    return false; /* No point in updating when it is virtually finished. */

  if (last_est.tv_sec == 0) {
    /* We don't have an estimate yet (probably means a low completion). */
    printit = true;
  } else if (TIMEVAL_AFTER(*now, last_est)) {
    /* The last estimate we printed has passed. Print a new one. */
    printit = true;
  } else {
    /* If the estimate changed by more than 3 minutes, and if that change
       represents at least 5% of the total time, print it. */
    double prev_est_total_time_s = difftime(last_est.tv_sec, begin.tv_sec);
    double prev_est_time_left_s = difftime(last_est.tv_sec, last_print.tv_sec);
    double change_abs_s = ABS(prev_est_time_left_s - time_left_s);
    if (o.debugging || (change_abs_s > 15 
          && change_abs_s > .05 * prev_est_total_time_s))
      printit = true;
  }

  if (printit) {
     return printStats(perc_done, now);
  } 

  return false;
}


/* Prints an estimate of when this scan will complete.  */
bool ScanProgressMeter::printStats(double perc_done, 
                                   const struct timeval *now) {
  struct timeval tvtmp;
  double time_left_s;
  time_t timet;
  struct tm ltime;
  int err;

  if (!now) {
    gettimeofday(&tvtmp, NULL);
    now = (const struct timeval *) &tvtmp;
  }

  last_print = *now;
  // If we're less than 1% done we probably don't have enough
  // data for decent timing estimates. Also with perc_done == 0
  // these elements will be nonsensical.
  if (perc_done < 0.01) {
    log_write(LOG_STDOUT, "About %.2f%% done\n",
        perc_done * 100);
    log_flush(LOG_STDOUT);
    return true;
  }

  /* Add 0.5 to get the effect of rounding in integer calculations. */
  time_left_s = estimate_time_left(perc_done, &begin, now) + 0.5;

  last_est = *now;
  last_est.tv_sec += (time_t)time_left_s;

  /* Get the estimated time of day at completion */
  timet = last_est.tv_sec;
  err = n_localtime(&timet, &ltime);

  if (!err) {
    log_write(LOG_STDOUT, "About %.2f%% done; ETC: %02d:%02d "
      "(%.f:%02.f:%02.f remaining)\n",
      perc_done * 100, ltime.tm_hour, ltime.tm_min,
      floor(time_left_s / 60.0 / 60.0),
      floor(fmod(time_left_s / 60.0, 60.0)),
      floor(fmod(time_left_s, 60.0)));
  /*log_write(LOG_XML, "<taskprogress task=\"%s\" time=\"%lu\" percent=\"%.2f\" remaining=\"%.f\" etc=\"%lu\" />\n",
      scantypestr, (unsigned long) now->tv_sec,
      perc_done * 100, time_left_s, (unsigned long) last_est.tv_sec); */
  } else {
    log_write(LOG_STDERR, "Timing error: n_localtime(%f): %s\n", (double) timet, strerror(err));
    log_write(LOG_STDOUT, "Timing: About %.2f%% done; ETC: Unknown (%.f:%02.f:%02.f remaining)\n",
        perc_done * 100,
        floor(time_left_s / 60.0 / 60.0),
        floor(fmod(time_left_s / 60.0, 60.0)),
        floor(fmod(time_left_s, 60.0)));
  }

  log_flush(LOG_STDOUT|LOG_XML);

  return true;
}




/* Indicates that the task is beginning or ending, and that a message should
   be generated if appropriate.  Returns whether a message was printed.
   now may be NULL, if the caller doesn't have the current time handy.
   additional_info may be NULL if no additional information is necessary. */
bool ScanProgressMeter::beginOrEndTask(const struct timeval *now, const char *additional_info, bool beginning) {
  struct timeval tvtmp;
  //struct tm *tm;
  //time_t tv_sec;

  if (!o.verbose) {
    return false;
  }

  if (!now) {
    gettimeofday(&tvtmp, NULL);
    now = (const struct timeval *) &tvtmp;
  }

  //tv_sec = now->tv_sec;
  //tm = localtime(&tv_sec);

  if (beginning) {
   // log_write(LOG_STDOUT, "Initiating %s at %02d:%02d", scantypestr, tm->tm_hour, tm->tm_min);
  //  log_write(LOG_XML, "<taskbegin task=\"%s\" time=\"%lu\"", scantypestr, (unsigned long) now->tv_sec);
    if (additional_info) {
      log_write(LOG_STDOUT, " (%s)", additional_info);
      //log_write(LOG_XML, " extrainfo=\"%s\"", additional_info);
    }
    log_write(LOG_STDOUT, "\n");
    //log_write(LOG_XML, " />\n");
  } else {
    //log_write(LOG_STDOUT, "Completed %s at %02d:%02d, %.2fs elapsed", scantypestr, tm->tm_hour, tm->tm_min, TIMEVAL_MSEC_SUBTRACT(*now, begin) / 1000.0);
  //  log_write(LOG_XML, "<taskend task=\"%s\" time=\"%lu\"", scantypestr, (unsigned long) now->tv_sec);
    if (additional_info) {
      log_write(LOG_STDOUT, " (%s)", additional_info);
      //log_write(LOG_XML, " extrainfo=\"%s\"", additional_info);
    }
    log_write(LOG_STDOUT, "\n");
    //log_write(LOG_XML, " />\n");
  }
  log_flush(LOG_STDOUT|LOG_XML);

  return true;
}
