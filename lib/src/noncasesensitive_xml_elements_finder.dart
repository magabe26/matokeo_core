import 'package:xml/xml.dart';

class NonCaseSensitiveXmlElementsFinder {
  static Iterable<XmlElement> findAllElements(
      XmlParent xmlParent, String name) {
    if ((xmlParent == null) || (name == null) || name.isEmpty) {
      return <XmlElement>[];
    }
    Iterable<XmlElement> elements = xmlParent.findAllElements(name);
    if ((elements == null) || elements.isEmpty) {
      elements = xmlParent.findAllElements(name.toLowerCase());
    }

    if ((elements == null) || elements.isEmpty) {
      elements = xmlParent.findAllElements(name.toUpperCase());
    }

    return elements ?? <XmlElement>[];
  }
}
