// g++ -O3 -g -o slingshot.exe Galaxy.cpp main.cpp

#include "Constants.hpp"
#include "Galaxy.hpp"
#include "Ship.hpp"
#include <cstdio>

int main(int argc, char** argv)
{
  const int numStars = 1000;
  const int radius = 1.0f;

  Ship ship;
  for (int k=0; k<ndim; k++) ship.r[k] = 0.0f;
  for (int k=0; k<ndim; k++) ship.v[k] = 0.0f;
  ship.v[0] = 2.0f;
  for (int k=0; k<ndim; k++) ship.v0[k] = ship.v[k];

  printf("Creating galaxy\n");
  Galaxy* galaxy = new Galaxy(numStars, radius);

  printf("Generating stars\n");
  galaxy->GenerateStars(100);
  galaxy->WriteStarsToFile();

  printf("Generating ship path\n");
  galaxy->CalculateShipPath(0.6f, ship);

  printf("Deleting galaxy\n");
  delete galaxy;

  return 1;
}
