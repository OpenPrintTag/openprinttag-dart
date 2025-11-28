// GENERATED CODE - DO NOT MODIFY BY HAND
// Source: data-submodule/data/material_type_enum.yaml
import 'material_class_enum.enum.g.dart';

enum MaterialTypeEnum {
  PLA(key: 0, name: 'Polylactic Acid', category: MaterialClassEnum.FFF),
  PETG(
    key: 1,
    name: 'Polyethylene Terephthalate Glycol',
    category: MaterialClassEnum.FFF,
  ),
  TPU(
    key: 2,
    name: 'Thermoplastic Polyurethane',
    category: MaterialClassEnum.FFF,
  ),
  ABS(
    key: 3,
    name: 'Acrylonitrile Butadiene Styrene',
    category: MaterialClassEnum.FFF,
  ),
  ASA(
    key: 4,
    name: 'Acrylonitrile Styrene Acrylate',
    category: MaterialClassEnum.FFF,
  ),
  PC(key: 5, name: 'Polycarbonate', category: MaterialClassEnum.FFF),
  PCTG(
    key: 6,
    name: 'Polycyclohexylenedimethylene Terephthalate Glycol',
    category: MaterialClassEnum.FFF,
  ),
  PP(key: 7, name: 'Polypropylene', category: MaterialClassEnum.FFF),
  PA6(key: 8, name: 'Polyamide 6', category: MaterialClassEnum.FFF),
  PA11(key: 9, name: 'Polyamide 11', category: MaterialClassEnum.FFF),
  PA12(key: 10, name: 'Polyamide 12', category: MaterialClassEnum.FFF),
  PA66(key: 11, name: 'Polyamide 66', category: MaterialClassEnum.FFF),
  CPE(key: 12, name: 'Copolyester', category: MaterialClassEnum.FFF),
  TPE(
    key: 13,
    name: 'Thermoplastic Elastomer',
    category: MaterialClassEnum.FFF,
  ),
  HIPS(
    key: 14,
    name: 'High Impact Polystyrene',
    category: MaterialClassEnum.FFF,
  ),
  PHA(key: 15, name: 'Polyhydroxyalkanoate', category: MaterialClassEnum.FFF),
  PET(
    key: 16,
    name: 'Polyethylene Terephthalate',
    category: MaterialClassEnum.FFF,
  ),
  PEI(key: 17, name: 'Polyetherimide', category: MaterialClassEnum.FFF),
  PBT(
    key: 18,
    name: 'Polybutylene Terephthalate',
    category: MaterialClassEnum.FFF,
  ),
  PVB(key: 19, name: 'Polyvinyl Butyral', category: MaterialClassEnum.FFF),
  PVA(key: 20, name: 'Polyvinyl Alcohol', category: MaterialClassEnum.FFF),
  PEKK(key: 21, name: 'Polyetherketoneketone', category: MaterialClassEnum.FFF),
  PEEK(
    key: 22,
    name: 'Polyether Ether Ketone',
    category: MaterialClassEnum.FFF,
  ),
  BVOH(
    key: 23,
    name: 'Butenediol Vinyl Alcohol Copolymer',
    category: MaterialClassEnum.FFF,
  ),
  TPC(
    key: 24,
    name: 'Thermoplastic Copolyester',
    category: MaterialClassEnum.FFF,
  ),
  PPS(key: 25, name: 'Polyphenylene Sulfide', category: MaterialClassEnum.FFF),
  PPSU(key: 26, name: 'Polyphenylsulfone', category: MaterialClassEnum.FFF),
  PVC(key: 27, name: 'Polyvinyl Chloride', category: MaterialClassEnum.FFF),
  PEBA(key: 28, name: 'Polyether Block Amide', category: MaterialClassEnum.FFF),
  PVDF(
    key: 29,
    name: 'Polyvinylidene Fluoride',
    category: MaterialClassEnum.FFF,
  ),
  PPA(key: 30, name: 'Polyphthalamide', category: MaterialClassEnum.FFF),
  PCL(key: 31, name: 'Polycaprolactone', category: MaterialClassEnum.FFF),
  PES(key: 32, name: 'Polyethersulfone', category: MaterialClassEnum.FFF),
  PMMA(
    key: 33,
    name: 'Polymethyl Methacrylate',
    category: MaterialClassEnum.FFF,
  ),
  POM(key: 34, name: 'Polyoxymethylene', category: MaterialClassEnum.FFF),
  PPE(key: 35, name: 'Polyphenylene Ether', category: MaterialClassEnum.FFF),
  PS(key: 36, name: 'Polystyrene', category: MaterialClassEnum.FFF),
  PSU(key: 37, name: 'Polysulfone', category: MaterialClassEnum.FFF),
  TPI(
    key: 38,
    name: 'Thermoplastic Polyimide',
    category: MaterialClassEnum.FFF,
  ),
  SBS(
    key: 39,
    name: 'Styrene-Butadiene-Styrene',
    category: MaterialClassEnum.FFF,
  ),
  OBC(key: 40, name: 'Olefin Block Copolymer', category: MaterialClassEnum.FFF);

  final int key;
  final String name;
  final MaterialClassEnum category;

  const MaterialTypeEnum({
    required this.key,
    required this.name,
    required this.category,
  });

  static MaterialTypeEnum byKey(int key) =>
      values.firstWhere((e) => e.key == key);
}
