/**
 * Author......: See docs/credits.txt
 * License.....: MIT
 */

#include "common.h"
#include "types.h"
#include "memory.h"
#include "event.h"
#include "shared.h"
#include "pidfile.h"

static int check_running_process (hashcat_ctx_t *hashcat_ctx)
{
  pidfile_ctx_t *pidfile_ctx = hashcat_ctx->pidfile_ctx;

  char *pidfile_filename = pidfile_ctx->filename;

  HCFILE fp;

  if (hc_fopen (&fp, pidfile_filename, "rb") == false) return 0;

  pidfile_data_t *pd = (pidfile_data_t *) hcmalloc (sizeof (pidfile_data_t));

  const size_t nread = hc_fread (pd, sizeof (pidfile_data_t), 1, &fp);

  hc_fclose (&fp);

  if (nread != 1)
  {
    //event_log_error (hashcat_ctx, "Cannot read %s", pidfile_filename);

    hcfree (pd);

    return 0;
  }

  if (pd->pid)
  {
    #if defined (_WIN)

    HANDLE hProcess = OpenProcess (PROCESS_ALL_ACCESS, FALSE, pd->pid);

    char *pidbin  = (char *) hcmalloc (HCBUFSIZ_LARGE);
    char *pidbin2 = (char *) hcmalloc (HCBUFSIZ_LARGE);

    int pidbin_len  = GetModuleFileName (NULL, pidbin, HCBUFSIZ_LARGE);
    int pidbin2_len = GetModuleFileNameEx (hProcess, NULL, pidbin2, HCBUFSIZ_LARGE);

    pidbin[pidbin_len]   = 0;
    pidbin2[pidbin2_len] = 0;

    if (pidbin2_len)
    {
      if (strcmp (pidbin, pidbin2) == 0)
      {
        event_log_error (hashcat_ctx, "Already an instance %s running on pid %d", pidbin2, pd->pid);

        hcfree (pd);

        hcfree (pidbin);
        hcfree (pidbin2);

        return -1;
      }
    }

    hcfree (pidbin);
    hcfree (pidbin2);

    #else

    char *pidbin;

    hc_asprintf (&pidbin, "/proc/%u/exe", pd->pid);

    if (hc_path_exist (pidbin) == true)
    {
      // pid info

      char *pidexe = (char *) hcmalloc (HCBUFSIZ_TINY);

      const ssize_t pidexe_len = readlink (pidbin, pidexe, HCBUFSIZ_TINY - 1);

      pidexe[pidexe_len] = 0;

      // self info

      char *selfexe = (char *) hcmalloc (HCBUFSIZ_TINY);

      const ssize_t selfexe_len = readlink ("/proc/self/exe", selfexe, HCBUFSIZ_TINY - 1);

      selfexe[selfexe_len] = 0;

      // compare

      const int r = strncmp (pidexe, selfexe, selfexe_len);

      if (r == 0)
      {
        event_log_error (hashcat_ctx, "Already an instance '%s' running on pid %u", pidexe, pd->pid);
      }

      hcfree (selfexe);

      hcfree (pidexe);

      hcfree (pd);

      hcfree (pidbin);

      if (r == 0) return -1;

      return 0;
    }

    hcfree (pidbin);

    #endif
  }

  hcfree (pd);

  return 0;
}

static int init_pidfile (hashcat_ctx_t *hashcat_ctx)
{
  pidfile_ctx_t *pidfile_ctx = hashcat_ctx->pidfile_ctx;

  pidfile_data_t *pd = (pidfile_data_t *) hcmalloc (sizeof (pidfile_data_t));

  pidfile_ctx->pd = pd;

  const int rc = check_running_process (hashcat_ctx);

  if (rc == -1) return -1;

  #if defined (_WIN)
  pd->pid = GetCurrentProcessId ();
  #else
  pd->pid = getpid ();
  #endif

  return 0;
}

static int write_pidfile (hashcat_ctx_t *hashcat_ctx)
{
  const pidfile_ctx_t *pidfile_ctx = hashcat_ctx->pidfile_ctx;

  pidfile_data_t *pd = pidfile_ctx->pd;

  char *pidfile_filename = pidfile_ctx->filename;

  HCFILE fp;

  if (hc_fopen (&fp, pidfile_filename, "wb") == false)
  {
    event_log_error (hashcat_ctx, "%s: %s", pidfile_filename, strerror (errno));

    return -1;
  }

  hc_fwrite (pd, sizeof (pidfile_data_t), 1, &fp);

  hc_fflush (&fp);

  hc_fclose (&fp);

  return 0;
}

int pidfile_ctx_init (hashcat_ctx_t *hashcat_ctx)
{
  folder_config_t *folder_config = hashcat_ctx->folder_config;
  pidfile_ctx_t   *pidfile_ctx   = hashcat_ctx->pidfile_ctx;
  user_options_t  *user_options  = hashcat_ctx->user_options;

  hc_asprintf (&pidfile_ctx->filename, "%s/%s.pid", folder_config->session_dir, user_options->session);

  pidfile_ctx->pidfile_written = false;

  const int rc_init_pidfile = init_pidfile (hashcat_ctx);

  if (rc_init_pidfile == -1) return -1;

  const int rc = write_pidfile (hashcat_ctx);

  if (rc == 0) pidfile_ctx->pidfile_written = true;

  return 0;
}

void pidfile_ctx_destroy (hashcat_ctx_t *hashcat_ctx)
{
  pidfile_ctx_t *pidfile_ctx = hashcat_ctx->pidfile_ctx;

  if (pidfile_ctx->pidfile_written == true)
  {
    unlink (pidfile_ctx->filename);
  }

  hcfree (pidfile_ctx->filename);

  hcfree (pidfile_ctx->pd);

  memset (pidfile_ctx, 0, sizeof (pidfile_ctx_t));
}
