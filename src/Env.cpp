/**
 * \file Env.cpp
 * \brief
 */

#include "Env.h"

PTR(Env) Env::empty = NEW(EmptyEnv)();
