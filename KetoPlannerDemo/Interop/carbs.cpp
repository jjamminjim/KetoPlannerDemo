
// carbs.cpp
#include <algorithm>

double cpp_net_carbs(double total, double fiber, double polyols) {
    const double net = total - fiber - (0.5 * polyols);
    return std::max(0.0, net);
}
