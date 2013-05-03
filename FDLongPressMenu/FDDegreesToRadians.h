static inline CGFloat FDDegreesToRadians(CGFloat degrees)
{
	CGFloat radians = degrees * M_PI / 180.0f;
	
	return radians;
}

static inline CGFloat FDRadiansToDegrees(CGFloat radians)
{
	CGFloat degrees = radians * 180.0f / M_PI;
	
	return degrees;
}