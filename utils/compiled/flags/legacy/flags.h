#ifndef FLAGS_H
#define FLAGS_H

// #define DEBUG

#include <iostream>
#include <cstdlib>
#include <stdint.h>
#include <string.h>
#include <vector>
#include <map>

// typedef std::vector<std::string> ParsedFlags;
typedef std::map<std::string, std::string> FlagMap;
typedef std::map<std::string, uint8_t> CheckTypeMap;

// "Options: HOME_DEV, MOBILE_DEV, WSL, SERVER, UNKNOWN"
FlagMap FlagNames{
    {"HOME", "hdev"},
    {"MOBILE", "sdev"},
    {"WSL", "WSL"},
    {"SERVER", "server"},
    {"UNKNOWN", "unknown"},
    {"BACKUP", "backup_env"}};

enum FilterTypes
{
    AND,
    OR,
};

CheckTypeMap TypeMap{
    {"all", AND},
    {"any", OR},
};

void print_help_information();

int verify_flag(const std::string &var);

int process_flags(const std::vector<std::string> &, const uint8_t check);

#endif