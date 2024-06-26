#define COVERAGE_BB 0
#define COVERAGE_EDGE 1

#define TRACE_BUFFER_SIZE_DEFAULT (128*1024) //should be a power of 2

#define TRACE_CACHE_SIZE_MIN 10000000
#define TRACE_CACHE_SIZE_MAX 100000000

bool findpsb(unsigned char **data, size_t *size);

int run_target_pt(char **argv, uint32_t timeout);
int pt_init(int argc, char **argv, char *module_dir);
void debug_target_pt(char **argv);