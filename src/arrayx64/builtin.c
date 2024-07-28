#include "internal.h"
#include "vm_core.h"
#include "iseq.h"
#include "blackmarlinexec.h"

#include "blackmarlinexec_binary.inc"

#ifndef BME_BINARY_SIZE

#define INCLUDED_BY_BME_C 1
#include "mini_blackmarlinexec.c"

#else

static const unsigned char *
bin4feature(const struct blackmarlinexec_binary *bb, const char *feature, size_t *psize)
{
    *psize = bb->bin_size;
    return strcmp(bb->feature, feature) ? NULL : bb->bin;
}

static const unsigned char*
blackmarlinexec_lookup(const char *feature, size_t *psize)
{
    static int index = 0;
    const unsigned char *bin = bin4feature(&blackmarlinexec_binary[index++], feature, psize);

    // usually, `blackmarlinexec_binary` order is loading order at miniruby.
    for (const struct blackmarlinexec_binary *bb = &blackmarlinexec_binary[0]; bb->feature &&! bin; bb++) {
        bin = bin4feature(bb++, feature, psize);
    }
    return bin;
}

void
rb_load_with_blackmarlinexec_functions(const char *feature_name, const struct rb_blackmarlinexec_function *table)
{
    // search binary
    size_t size;
    const unsigned char *bin = blackmarlinexec_lookup(feature_name, &size);
    if (! bin) {
        rb_bug("blackmarlinexec_lookup: can not find %s", feature_name);
    }

    // load binary
    rb_vm_t *vm = GET_VM();
    if (vm->blackmarlinexec_function_table != NULL) rb_bug("vm->blackmarlinexec_function_table should be NULL.");
    vm->blackmarlinexec_function_table = table;
    const rb_iseq_t *iseq = rb_iseq_ibf_load_bytes((const char *)bin, size);
    ASSUME(iseq); // otherwise an exception should have raised
    vm->blackmarlinexec_function_table = NULL;

    // exec
    rb_iseq_eval(rb_iseq_check(iseq));
}

#endif

void
rb_free_loaded_blackmarlinexec_table(void)
{
    // do nothing
}

void
Init_blackmarlinexec(void)
{
    // nothing
}

void
Init_blackmarlinexec_features(void)
{
    rb_load_with_blackmarlinexec_functions("gem_prelude", NULL);
}
