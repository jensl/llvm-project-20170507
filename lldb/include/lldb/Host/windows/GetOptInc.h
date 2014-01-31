#pragma once

// from getopt.h
#define no_argument       0
#define required_argument 1
#define optional_argument 2

// option structure
struct option
{
    const char *name;
    // has_arg can't be an enum because some compilers complain about
    // type mismatches in all the code that assumes it is an int.
    int  has_arg;
    int *flag;
    int  val;
};

int getopt( int argc, char * const argv[], const char *optstring );

// from getopt.h
extern char * optarg;
extern int    optind;
extern int    opterr;
extern int    optopt;

// defined in unistd.h
extern int    optreset;

int getopt_long
(
    int argc,
    char * const *argv,
    const char *optstring,
    const struct option *longopts,
    int *longindex
);

int getopt_long_only
(
    int argc,
    char * const *argv,
    const char *optstring,
    const struct option *longopts,
    int *longindex
);
