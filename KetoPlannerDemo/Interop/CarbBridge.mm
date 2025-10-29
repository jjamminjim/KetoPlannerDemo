
// CarbBridge.mm
#import "CarbBridge.h"

double cpp_net_carbs(double total, double fiber, double polyols);

double NetCarbsFromTotal(double total, double fiber, double polyols) {
    return cpp_net_carbs(total, fiber, polyols);
}
