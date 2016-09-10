#ifndef _SHIP_HPP_
#define _SHIP_HPP_

#include "Constants.hpp"

struct Ship {
  float m;
  float r[ndim];
  float v[ndim];
  float v0[ndim];
  float a[ndim];
  float a0[ndim];
};

#endif
