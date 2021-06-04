enum LabelType { phone, email, address }

//TODO: eventually one could allow saving of custom labels

//default match those on an iPhone 12 on June 4th 2021
class CategoryData {
  static List<String> defaultPhoneLabels = [
    "mobile",
    "home",
    "work",
    "school",
    "iPhone",
    "Apple Watch",
    "main",
    "home fax",
    "work fax",
    "pager",
    "other",
  ];

  static List<String> defaultEmailLabels = [
    "home",
    "work",
    "school",
    "iCloud",
    "other",
  ];

  static List<String> defaultAddressLabels = [
    "home",
    "work",
    "school",
    "other",
  ];

  static Map<LabelType, List<String>> labelTypeToDefaultLabels = {
    LabelType.phone: defaultPhoneLabels,
    LabelType.email: defaultEmailLabels,
    LabelType.address: defaultAddressLabels,
  };

  static Map<LabelType, String> labelTypeToCategoryName = {
    LabelType.phone: "phone number",
    LabelType.email: "email address",
    LabelType.address: "address",
  };
}
