#ifndef _CLOCK_H_
#define _CLOCK_H_

#include "stdint.h"

uint64_t get_cycles();
void clock_set_next_event();

#endif