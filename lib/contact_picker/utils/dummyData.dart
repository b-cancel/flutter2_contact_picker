import 'package:contacts_service/contacts_service.dart';

Contact dummyContact = Contact(
  //display name
  givenName: "givenName",
  middleName: "middleName",
  familyName: "familyName",
  prefix: "prefix",
  suffix: "suffix",
  company: "company",
  jobTitle: "job title",
  //emails
  //phones
  //addresses
);

Contact getDummyContact() {
  List<Item> phones = [];

  phones.add(Item(label: "mobile", value: "956 777 2692"));
  dummyContact.phones = phones;

  List<Item> emails = [];
  emails.add(Item(label: "email", value: "some@s.com"));
  dummyContact.emails = emails;

  List<PostalAddress> addresses = [];
  addresses.add(
    PostalAddress(
      label: "label",
      street: "street",
      city: "city",
      postcode: "78912",
      region: "region",
      country: 'US',
    ),
  );

  return dummyContact;
}
