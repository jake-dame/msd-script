/**
 * \file parse.h
 * \brief Parsing functions declaration
 */

#pragma once

#include "Expr.h"
#include "pointers.h"

PTR(Expr) parse_expr(const std::string &str);
