#include <iostream>
#include "math.h"
using namespace std;

int main()
{
     double a, b, c, d, e;
     cout << "Введите a:" << endl;
     cin >> a;
     cout << "Введите b:" << endl;
     cin >> b;
     cout << "Введите c:" << endl;
     cin >> c;
     cout << "Введите d:" << endl;
     cin >> d;
     cout << "Введите e:" << endl;
     cin >> e;
     cout << "Формула - res = (a*e-b*c+d/b)/((b+c)*a)" << endl;
     cout << "a*e = ";
     cout << a*e << endl;
     cout << "b*c = ";
     cout << b*c << endl;
     cout << "d/b = ";
     cout << d/b << endl;
     cout << "a*e-b*c = ";
     cout << a*e-b*c << endl;
     cout << "a*e-b*c+d/b = ";
     cout << a*e-b*c+d/b << endl;
     cout << "b+c = ";
     cout << b+c << endl;
     cout << "(b+c)*a = ";
     cout << (b+c)*a << endl;
     cout << "res = ";
     cout << (a*e-b*c+d/b)/((b+c)*a) << endl;
}
