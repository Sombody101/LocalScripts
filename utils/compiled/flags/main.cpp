#include "flags.h"

void print_help_information()
{
    std::cout << "flag: [filter type] [flag] [flag...]" << std::endl;
    std::cout << std::endl;

    std::cout << "    Flags:" << std::endl;
    for (const auto &pair : FlagNames)
        std::cout << "\t" << pair.first << "\t (" << pair.second << ')' << std::endl;
    std::cout << std::endl;

    std::cout << "\t--flags: Print all available flags and their environment mappings." << std::endl;
    std::cout << "\t--help:  Print this help menu." << std::endl;
    std::cout << std::endl;

    std::cout << "    Filters:" << std::endl;
    std::cout << "\tand: [DEFAULT] All or none of the flags." << std::endl;
    std::cout << "\t    Returns 0 if all given flags are set to 'TRUE'." << std::endl;
    std::cout << "\t\t(flag && flag && ...)" << std::endl;
    std::cout << "\tany: Any one of the flags." << std::endl;
    std::cout << "\t    Returns 0 if any given flag is set to 'TRUE'." << std::endl;
    std::cout << "\t\t(flag || flag || ...)" << std::endl;

    std::cout << std::endl;
    std::cout << "    Returns:" << std::endl;
    std::cout << "\t0: If all flags met the requirements." << std::endl;
    std::cout << "\t1: If one or no flags met the requirements." << std::endl;
    std::cout << "\t2: Unknown flag." << std::endl;
}

int verify_flag(const std::string &var)
{
    char *evar = std::getenv(var.c_str());

    if (evar == nullptr)
        return false;

    if (strcmp(evar, "TRUE") == 0)
        return true;

    return false;
}

int process_flags(const std::vector<std::string> &args, const uint8_t check)
{
    const int args_len = args.size();

    int last_result{check};

    for (int i{0}; i < args_len; ++i)
    {
        std::string flag = args.at(i);

#ifdef DEBUG
        std::cout << "Working on: " << flag << std::endl;
#endif

        if (FlagNames.find(flag) == FlagNames.end())
        {
            std::cerr << "Unknown flag '" << flag << "'" << std::endl;
            last_result = 2;
            continue;
        }

        flag = FlagNames[flag];
        int is_set = verify_flag(flag);

#ifdef DEBUG
        std::cout << "Is set: " << is_set << std::endl;
#endif

        // Stop scanning for flags
        if (last_result > 1)
            continue;

        switch (check)
        {
        case AND:
            if (!is_set)
                last_result = 1;
            break;

        case OR:
            if (is_set)
                last_result = 0;
            break;
        }

#ifdef DEBUG
        std::cout << "Result: " << last_result << std::endl;
#endif
    }

#ifdef DEBUG
    std::cout << "Final output: " << last_result << std::endl;
#endif
    return last_result;
}

int main(int argc, char *argv[])
{
    std::vector<std::string> args;
    for (int i{1}; i < argc; ++i)
        args.push_back(argv[i]);
    --argc;

#ifdef DEBUG
    for (int i{0}; i < argc; ++i)
        std::cout << "I:" << i << " T: " << args.at(i) << std::endl;
#endif

    if (argc == 0)
        // No flags to check
        return EXIT_SUCCESS;

    if (args.at(0) == "--help")
    {
        print_help_information();
        return EXIT_SUCCESS;
    }
    else if (args.at(0) == "--flags")
    {
        for (const auto &pair : FlagNames)
            std::cout << pair.first << " : " << pair.second << std::endl;
        return EXIT_SUCCESS;
    }

    uint8_t check_type{AND};

    if (TypeMap.find(args.at(0)) != TypeMap.end())
    {
        check_type = TypeMap[args.at(0)];
        args.erase(args.begin());
    }

#ifdef DEBUG
    std::cout << "Len: " << args.size() << std::endl;
#endif

    return process_flags(args, check_type);
}