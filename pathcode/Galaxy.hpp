#include "Constants.hpp"
#include "Ship.hpp"

struct Star {
  float m;
  float r[ndim];
};

class Galaxy {

private:
  int numStars;
  float radius;
  Star* stars;


public:
  Galaxy(const int, const float);
  ~Galaxy();

  void CalculateShipAcceleration(Ship&);
  bool CalculateShipPath(const float, const Ship&);
  bool GenerateStars(const int);

  void WriteStarsToFile();

};
