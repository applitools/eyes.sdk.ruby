# frozen_string_literal: false
module Devices
  extend self
  IPhone4 = 'iPhone 4'.freeze
  IPhone5SE = 'iPhone 5/SE'.freeze
  IPhone678 = 'iPhone 6/7/8'.freeze
  IPhone678Plus = 'iPhone 6/7/8 Plus'.freeze
  IPhoneX = 'iPhone X'.freeze
  IPad = 'iPad'.freeze
  IPadPro = 'iPad Pro'.freeze
  BlackBerryZ30 = 'BlackBerry Z30'.freeze
  Nexus4 = 'Nexus 4'.freeze
  Nexus5 = 'Nexus 5'.freeze
  Nexus5X = 'Nexus 5X'.freeze
  Nexus6 = 'Nexus 6'.freeze
  Nexus6P = 'Nexus 6P'.freeze
  Pixel2 = 'Pixel 2'.freeze
  Pixel2XL = 'Pixel 2 XL'.freeze
  LGOptimusL70 = 'LG Optimus L70'.freeze
  NokiaN9 = 'Nokia N9'.freeze
  NokiaLumia520 = 'Nokia Lumia 520'.freeze
  MicrosoftLumia550 = 'Microsoft Lumia 550'.freeze
  MicrosoftLumia950 = 'Microsoft Lumia 950'.freeze
  GalaxyS3 = 'Galaxy S III'.freeze
  GalaxyS5 = 'Galaxy S5'.freeze
  KindleFireHDX = 'Kindle Fire HDX'.freeze
  IPadMini = 'iPad Mini'.freeze
  BlackberryPlayBook = 'Blackberry PlayBook'.freeze
  Nexus10 = 'Nexus 10'.freeze
  Nexus7 = 'Nexus 7'.freeze
  GalaxyNote3 = 'Galaxy Note 3'.freeze
  GalaxyNote2 = 'Galaxy Note II'.freeze
  LaptopWithTouch = 'Laptop with touch'.freeze
  LaptopWithHDPIScreen = 'Laptop with HiDPI screen'.freeze
  LaptopWithMDPIScreen = 'Laptop with MDPI screen'.freeze

  def enum_values
    [
      IPhone4, IPhone5SE, IPhone678, IPhone678Plus, IPhoneX, IPad, IPadPro, BlackBerryZ30, Nexus4, Nexus5, Nexus5X,
      Nexus6, Nexus6P, Pixel2, Pixel2XL, LGOptimusL70, NokiaN9, NokiaLumia520, MicrosoftLumia550, MicrosoftLumia950,
      GalaxyS3, GalaxyS5, KindleFireHDX, IPadMini, BlackberryPlayBook, Nexus10, Nexus7, GalaxyNote3, GalaxyNote2,
      LaptopWithTouch, LaptopWithHDPIScreen, LaptopWithMDPIScreen
    ]
  end
end
