
/* kinect.c */
#include <erl_nif.h>
#include "inc/libfreenect.h"
#include <string.h>
#include <sys/stat.h>

// Byte array for svpng
struct byte_array
{
  unsigned char *ptr;
  unsigned int len;
  unsigned int cap;
};

static void byte_array_push(unsigned char u, struct byte_array *ba)
{
  ba->len = ba->len + 1;
  if (ba->len == ba->cap)
  {
    ba->cap *= 2;
    ba->ptr = realloc(ba->ptr, ba->cap);
  }
  ba->ptr[ba->len - 1] = u;
}

static void new_byte_array(struct byte_array *ba)
{
  ba->len = 0;
  ba->cap = 64;
  ba->ptr = malloc(ba->cap);
}

// end byte array for svpng

#define SVPNG_OUTPUT struct byte_array *ba
#define SVPNG_PUT(u) byte_array_push(u, ba)

#include "inc/svpng.inc"

// Start nif resource stuff

ErlNifResourceType *CTX_RES_TYPE;
ErlNifResourceType *DEV_RES_TYPE;

static ErlNifPid video_callback_pid;

static void ctx_res_destructor(ErlNifEnv *env, void *res)
{
  freenect_shutdown(*((freenect_context **)res));
}

static void dev_res_destructor(ErlNifEnv *env, void *res)
{
  // freenect_close_device(*((freenect_device **)res));
}

static int nif_load(ErlNifEnv *env, void **priv_data, ERL_NIF_TERM load_info)
{
  int flags = ERL_NIF_RT_CREATE | ERL_NIF_RT_TAKEOVER;

  CTX_RES_TYPE = enif_open_resource_type(env, NULL, "ctx", ctx_res_destructor, flags, NULL);
  if (CTX_RES_TYPE == NULL)
    return -1;

  DEV_RES_TYPE = enif_open_resource_type(env, NULL, "dev", dev_res_destructor, flags, NULL);
  if (DEV_RES_TYPE == NULL)
    return -1;

  return 0;
}
// End nif resource stuff

/* Helper functions */

static freenect_device *get_device(ErlNifEnv *env, ERL_NIF_TERM arg)
{
  freenect_device **dev_res;
  enif_get_resource(env, arg, DEV_RES_TYPE, (void **)&dev_res);
  freenect_device *dev = *dev_res;
  return dev;
}

static freenect_context *get_context(ErlNifEnv *env, ERL_NIF_TERM arg)
{
  freenect_context **ctx_res;
  enif_get_resource(env, arg, CTX_RES_TYPE, (void **)&ctx_res);
  freenect_context *ctx = *ctx_res;
  return ctx;
}

/* end helper functions */

static ERL_NIF_TERM kinext_freenect_init(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
  srand(time(0));
  freenect_context **ctx_res = enif_alloc_resource(CTX_RES_TYPE, sizeof(freenect_context *));
  freenect_context *ctx;
  int success = freenect_init(&ctx, 0);
  if (success == 0)
  {
    // freenect_set_log_level(ctx, FREENECT_LOG_DEBUG);
    memcpy((void *)ctx_res, (void *)&ctx, sizeof(freenect_context *));
    ERL_NIF_TERM term = enif_make_resource(env, ctx_res);
    enif_release_resource(ctx_res);
    enif_fprintf(stdout, "initialized\n");
    return term;
  }
  else
  {
    return enif_make_int(env, success);
  }
}

static ERL_NIF_TERM kinext_freenect_shutdown(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
  if (argc != 1)
    return enif_make_int(env, -1);
  freenect_context *ctx = get_context(env, argv[0]);
  int success = freenect_shutdown(ctx);
  return enif_make_int(env, success);
}

static ERL_NIF_TERM kinext_freenect_num_devices(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
  if (argc != 1)
    return enif_make_int(env, -1);
  freenect_context *ctx = get_context(env, argv[0]);
  return enif_make_int(env, freenect_num_devices(ctx));
}

static ERL_NIF_TERM kinext_freenect_open_device(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
  if (argc != 2)
    return enif_make_int(env, -3);
  freenect_context *ctx = get_context(env, argv[0]);
  int index;
  if (!enif_get_int(env, argv[1], &index))
    return enif_make_int(env, -2);

  freenect_device **dev_res = enif_alloc_resource(DEV_RES_TYPE, sizeof(freenect_device *));
  freenect_device *dev;
  int success = freenect_open_device(ctx, &dev, 0);
  if (success == 0)
  {
    memcpy((void *)dev_res, (void *)&dev, sizeof(freenect_device *));
    ERL_NIF_TERM term = enif_make_resource(env, dev_res);
    enif_release_resource(dev_res);
    return term;
  }
  else
  {
    return enif_make_int(env, success);
  }
}

static ERL_NIF_TERM kinext_freenect_set_led(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
  if (argc != 2)
    return enif_make_int(env, -1);
  freenect_device *dev = get_device(env, argv[0]);

  int led_color;
  if (!enif_get_int(env, argv[1], &led_color))
    return enif_make_int(env, -2);

  return enif_make_int(env, freenect_set_led(dev, led_color));
}

static ERL_NIF_TERM kinext_freenect_get_tilt_degs(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
  if (argc != 1)
    return enif_make_int(env, -99);
  freenect_device *dev = get_device(env, argv[0]);

  int success = freenect_update_tilt_state(dev);
  if (!success)
    return enif_make_int(env, -98);

  freenect_raw_tilt_state *tilt_state = freenect_get_tilt_state(dev);

  return enif_make_double(env, freenect_get_tilt_degs(tilt_state));
}

static ERL_NIF_TERM kinext_freenect_set_tilt_degs(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
  if (argc != 2)
    return enif_make_int(env, -99);
  freenect_device *dev = get_device(env, argv[0]);

  double tilt_degs;
  if (!enif_get_double(env, argv[1], &tilt_degs))
    return enif_make_int(env, -98);

  return enif_make_int(env, freenect_set_tilt_degs(dev, tilt_degs));
}

static int send_data_to_pid(void *data)
{

  struct byte_array *ba;
  new_byte_array(ba);
  svpng(ba, 640, 480, data, 0);
  ErlNifEnv *env = enif_alloc_env();
  ERL_NIF_TERM erl_bin;
  unsigned char *erl_bin_term = enif_make_new_binary(env, ba->len, &erl_bin);
  memcpy((char *)erl_bin_term, (unsigned char *)ba->ptr, ba->len);
  free(ba->ptr);
  if (enif_send(NULL, &video_callback_pid, env, erl_bin))
  {
    return 0;
  }
  else
  {
    enif_fprintf(stdout, "Faild to send to pid\n");
    return -1;
  }
}

static void video_cb(freenect_device *dev, void *data, uint32_t timestamp)
{
  //segfault if we remove this line??
  enif_fprintf(stdout, "video_cb happened\n");
  send_data_to_pid(data);
}

static ERL_NIF_TERM kinext_start_video(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
  if (argc != 2)
    return enif_make_int(env, -1);
  freenect_device *dev = get_device(env, argv[0]);
  if (enif_get_local_pid(env, argv[1], &video_callback_pid) < 0)
    return enif_make_int(env, -2);

  // freenect_frame_mode depth_mode = freenect_find_depth_mode(FREENECT_RESOLUTION_MEDIUM, FREENECT_DEPTH_MM);
  // if (freenect_set_depth_mode(dev, depth_mode) < 0)
  //   return enif_make_int(env, -3);
  freenect_frame_mode video_mode = freenect_find_video_mode(FREENECT_RESOLUTION_MEDIUM, FREENECT_VIDEO_RGB);
  if (freenect_set_video_mode(dev, video_mode) < 0)
    return enif_make_int(env, -3);

  freenect_set_video_callback(dev, video_cb);

  return enif_make_int(env, freenect_start_video(dev));
}

static ERL_NIF_TERM kinext_freenect_process_events(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
  if (argc != 1)
    return enif_make_int(env, -1);
  freenect_context *ctx = get_context(env, argv[0]);
  struct timeval timeout;
  timeout.tv_sec = 0;
  timeout.tv_usec = 0;

  return enif_make_int(env, freenect_process_events_timeout(ctx, &timeout));
}

/* declare functions to export (and corresponding arity) */
static ErlNifFunc nif_funcs[] = {
    {"freenect_init", 0, kinext_freenect_init},
    {"freenect_shutdown", 1, kinext_freenect_shutdown},
    {"freenect_num_devices", 1, kinext_freenect_num_devices},
    {"freenect_open_device", 2, kinext_freenect_open_device},
    {"freenect_set_led", 2, kinext_freenect_set_led},
    {"freenect_get_tilt_degs", 1, kinext_freenect_get_tilt_degs},
    {"freenect_set_tilt_degs", 2, kinext_freenect_set_tilt_degs},
    {"kinext_start_video", 2, kinext_start_video},
    {"freenect_process_events", 1, kinext_freenect_process_events}};

/* actually export the functions previously declared */
ERL_NIF_INIT(Elixir.Kinext.Native, nif_funcs, nif_load, NULL, NULL, NULL);