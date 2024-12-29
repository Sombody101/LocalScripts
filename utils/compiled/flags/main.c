/*
 * Is it good? Absolutely not.
 * Does it work? Hopefully...
 */

#include <assert.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// #define DEBUG

int remove_at(const int index, const int len, const char *arr[]) {
  int newlen = len - 1;
  memmove(arr + index, arr + index + 1, (newlen - index) * sizeof(*arr));
  return newlen;
}

/*
 * Filter keywords
 */

enum FilterType { AND, OR } filter_type;

const char *filter_tags[] = {"all", "any"};

/*
 * Flag Names
 */

const char *flags_public[] = {"HOME",   "MOBILE",  "WSL",
                              "SERVER", "UNKNOWN", "BACKUP"};

const char *flags_real[] = {"hdev",   "sdev",    "WSL",
                            "server", "unknown", "backup_env"};

const int flags_public_len = sizeof(flags_public) / sizeof(flags_public[0]);
const int flags_real_len = sizeof(flags_real) / sizeof(flags_real[0]);

void print_flag_pairs(const char *prefix) {
  for (int i = 0; i < flags_real_len; ++i) {
    printf("%s%s\t (%s)\n", prefix, flags_public[i], flags_real[i]);
  }
}

const char *resolve_flag(const char *flag) {
  for (int i = 0; i < flags_public_len; ++i) {
    const char *public_flag = flags_public[i];
    if (strcmp(public_flag, flag) == 0) {
      return flags_real[i];
    }
  }

  return NULL;
}

int verify_flag(const char *flag) {
  const char *evar = getenv(flag);

#ifdef DEBUG
  printf("'%s' text: %s\n", flag, evar);
#endif

  if (evar != NULL && strcmp(evar, "TRUE") == 0) {
    return 1;
  }

  return 0;
}

/*
 * Print help information to the console.
 */
void print_help_information() {
  printf("flag: [filter type] [flag] [flag...]\n\n");

  printf("    Flags:\n");
  print_flag_pairs("\t");

  printf("\n\t--flags: Print all available flags and their environment "
         "mappings.\n");
  printf("\t--help:  Print this help menu.\n\n");

  printf("    Filters:\n");
  printf("\tall: [DEFAULT] All or none of the flags.\n");
  printf("\t    Returns 0 if all given flags are set to 'TRUE'.\n");
  printf("\t\t(flag && flag && ...)\n");
  printf("\tany: Any one of the flags.\n");
  printf("\t    Returns 0 if any given flag is set to 'TRUE'.\n");
  printf("\t\t(flag || flag || ...)\n\n");

  printf("    Returns:\n");
  printf("\t0: If all flags met the requirements.\n");
  printf("\t1: If one or no flags met the requirements.\n");
  printf("\t2: Unknown flag.\n");
}

int parse_flags(const int argc, const char *args[]) {
  int result = filter_type;

  for (int i = 0; i < argc; ++i) {
    const char *flag = args[i];

#ifdef DEBUG
    printf("Working on: %s\n", flag);
#endif

    const char *public_flag = resolve_flag(flag);

    if (public_flag == NULL) {
      printf("Unknown flag '%s'\n", flag);
      result = 2;
      continue;
    }

    int flag_is_set = verify_flag(public_flag);

#ifdef DEBUG
    printf("Is set: %d\n", flag_is_set);
#endif

    // if (result > 1) {
    //   continue;
    // }

    switch (filter_type) {
    case AND:
      if (!flag_is_set) {
        result = 1;
      }

#ifdef DEBUG
      printf("AND -> %d\n", result);
#endif
      break;

    case OR:
      if (flag_is_set) {
#ifdef DEBUG
        printf("OR -> 0; Exiting\n");
#endif
        return 0;
      }
    }
  }

#ifdef DEBUG
  printf("out: %d\n", result);
#endif

  return result;
}

/*
 * Entry Point
 */

int main(int argc, const char *args[]) {

  // No args given, just exit.
  if (argc == 1) {
    return 0;
  }

  assert(flags_public_len == flags_real_len);

#ifdef DEBUG
  printf("Arg count: %d\n", argc);
  for (int i = 0; i < argc; ++i) {
    printf("Ind:%d, Txt:%s\n", i, args[i]);
  }
#endif

  const char *first = args[1];

#ifdef DEBUG
  printf("First arg: %s\n", first);
#endif

  if (strcmp(first, "--help") == 0) {
    print_help_information();
    return 0;
  } else if (strcmp(first, "--flags") == 0) {
    print_flag_pairs("");
    return 0;
  }

  // Get flag parse type (defaults to AND)
  if (strcmp(first, "any") == 0) {
    filter_type = OR;
    argc = remove_at(1, argc, args);
  } else if (strcmp(first, "all") == 0) {
    argc = remove_at(1, argc, args);
  }

  // Remove the executable path
  argc = remove_at(0, argc, args);

#ifdef DEBUG
  printf("Final arg count: %d\n", argc);
  for (int i = 0; i < argc; ++i) {
    printf("Ind:%d, Txt:%s\n", i, args[i]);
  }
#endif

  return parse_flags(argc, args);
}