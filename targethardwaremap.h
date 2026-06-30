#ifndef TARGETHARDWAREMAP_H
#define TARGETHARDWAREMAP_H

namespace TargetHardwareMap {

constexpr int HardwareStatusRegister = 0x1000;
constexpr int ShotCountRegister = 0x2000;
constexpr int ResetShotCountRegister = 0x2001;
constexpr int PaperFeedControlRegister = 0x2004;
constexpr int PaperFeedDurationRegister = 0x2005;
constexpr int PaperFeedRadiusRegister = 0x2006;

constexpr int FirstShotDataRegister = 16376;
constexpr int RegistersPerShot = 8;
constexpr int HardwareShotBufferSize = 10;
constexpr int AutomaticPaperFeedMode = 0x0100;
constexpr int DefaultPaperFeedRadius = 0x1000;

inline int shotDataRegister(int oneBasedShotNumber)
{
    return FirstShotDataRegister + (RegistersPerShot * oneBasedShotNumber);
}

}

#endif // TARGETHARDWAREMAP_H
