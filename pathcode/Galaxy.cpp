#include "Galaxy.hpp"
#include <cstdlib>
#include <fstream>
#include <math.h>
#include <ostream>
#include <string>

Galaxy::Galaxy(const int _numStars, const float _radius)
{
  numStars = _numStars;
  radius = _radius;
  stars = new Star[numStars];
}

Galaxy::~Galaxy()
{
  delete[] stars;
}

void Galaxy::CalculateShipAcceleration(Ship& ship)
{
  float drsqd;
  float dr[ndim];
  for (int k=0; k<ndim; k++) ship.a[k] = 0.0f;
  for (int i=0; i<numStars; i++) {
    for (int k=0; k<ndim; k++) dr[k] = stars[i].r[k] - ship.r[k];
    drsqd = 0.0f;
    for (int k=0; k<ndim; k++) drsqd += dr[k]*dr[k];
    float drmag = sqrtf(drsqd + etaGrav*etaGrav);
    for (int k=0; k<ndim; k++) ship.a[k] += Gconst*stars[i].m*dr[k]/drmag/drmag/drmag;
  }
}

bool Galaxy::CalculateShipPath(const float radViewMax, const Ship& _ship)
{
  Ship ship = _ship;
  float rold[ndim];
  float radShipSqd = 0.0f;
  float timestep;

  std::string filename = "path.dat";
  std::ofstream outfile;
  outfile.open(filename.c_str());

  CalculateShipAcceleration(ship);

  for (int k=0; k<ndim; k++) rold[k] = ship.r[k];


  // Main Verlet integration loop for ship path
  //---------------------------------------------------------------------------
  do {

    // Record velocity and acceleration at beginning of step
    for (int k=0; k<ndim; k++) ship.v0[k] = ship.v[k];
    for (int k=0; k<ndim; k++) ship.a0[k] = ship.a[k];

    // Calculate adaptive timestep
    float asqd = 0.0f;
    for (int k=0; k<ndim; k++) asqd += ship.a[k]*ship.a[k];
    timestep = timeMult*sqrtf(etaGrav/sqrtf(asqd));

    // Verlet prediction step
    for (int k=0; k<ndim; k++) {
      ship.r[k] += ship.v0[k]*timestep + 0.5*ship.a0[k]*timestep*timestep;
      ship.v[k] += ship.a0[k]*timestep;
    }

    // Calculate acceleration of ship due to surrounding stars/planets
    CalculateShipAcceleration(ship);

    // Verlet correction step
    for (int k=0; k<ndim; k++) {
      ship.v[k] = ship.v0[k] + 0.5f*(ship.a0[k] + ship.a[k])*timestep;
    }

    // Output ship path to file
    outfile << rold[0];
    for (int k=1; k<ndim; k++) outfile << "  " << rold[k];
    outfile << std::endl;
    outfile << ship.r[0];
    for (int k=1; k<ndim; k++) outfile << "  " << ship.r[k];
    outfile << std::endl;
    outfile << std::endl;

    for (int k=0; k<ndim; k++) rold[k] = ship.r[k];

    // Calculate distance of ship from original position (for termination)
    radShipSqd = 0.0f;
    for (int k=0; k<ndim; k++) {
      radShipSqd += (ship.r[k] - _ship.r[k])*(ship.r[k] - _ship.r[k]);
    }


  } while (radShipSqd < radViewMax*radViewMax);
  //---------------------------------------------------------------------------

  outfile.close();

  return true;
}

bool Galaxy::GenerateStars(const int _seed)
{
  float radsqd;
  for (int i=0; i<numStars; i++) {
    stars[i].m = (float) ((rand()%RAND_MAX)/(float)RAND_MAX);
    do {
      radsqd = 0.0f;
      for (int k=0; k<ndim; k++) {
        float randfloat = (float) ((rand()%RAND_MAX)/(float)RAND_MAX);
        stars[i].r[k] = 1.0 - 2.0*randfloat;
        radsqd += stars[i].r[k]*stars[i].r[k];
      }
    } while (radsqd > radius*radius);
  }

  return true;
}

void Galaxy::WriteStarsToFile()
{
  std::string filename = "stars.dat";
  std::ofstream outfile;
  outfile.open(filename.c_str());

  for (int i=0; i<numStars; i++) {
    outfile << stars[i].r[0];
    for (int k=1; k<ndim; k++) outfile << "  " << stars[i].r[k];
    outfile << std::endl;
  }

  outfile.close();

  return;
}
