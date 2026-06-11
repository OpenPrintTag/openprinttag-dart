// GENERATED CODE - DO NOT MODIFY BY HAND
// Source: data-submodule/data/material_type_enum.yaml
enum MaterialTypeEnum {
  PLA(key: 0, name: 'Polylactic Acid'),
  PETG(key: 1, name: 'Polyethylene Terephthalate Glycol'),
  TPU(key: 2, name: 'Thermoplastic Polyurethane'),
  ABS(key: 3, name: 'Acrylonitrile Butadiene Styrene'),
  ASA(key: 4, name: 'Acrylonitrile Styrene Acrylate'),
  PC(key: 5, name: 'Polycarbonate'),
  PCTG(key: 6, name: 'Polycyclohexylenedimethylene Terephthalate Glycol'),
  PP(key: 7, name: 'Polypropylene'),
  PA6(key: 8, name: 'Polyamide 6'),
  PA11(key: 9, name: 'Polyamide 11'),
  PA12(key: 10, name: 'Polyamide 12'),
  PA612(key: 42, name: 'Polyamide 612'),
  PA66(key: 11, name: 'Polyamide 66'),
  CPE(key: 12, name: 'Copolyester'),
  TPE(key: 13, name: 'Thermoplastic Elastomer'),
  HIPS(key: 14, name: 'High Impact Polystyrene'),
  PHA(key: 15, name: 'Polyhydroxyalkanoate'),
  PET(key: 16, name: 'Polyethylene Terephthalate'),
  PEI(key: 17, name: 'Polyetherimide'),
  PBT(key: 18, name: 'Polybutylene Terephthalate'),
  PVB(key: 19, name: 'Polyvinyl Butyral'),
  PVA(key: 20, name: 'Polyvinyl Alcohol'),
  PEKK(key: 21, name: 'Polyetherketoneketone'),
  PEEK(key: 22, name: 'Polyether Ether Ketone'),
  BVOH(key: 23, name: 'Butenediol Vinyl Alcohol Copolymer'),
  TPC(key: 24, name: 'Thermoplastic Copolyester'),
  PPS(key: 25, name: 'Polyphenylene Sulfide'),
  PPSU(key: 26, name: 'Polyphenylsulfone'),
  PVC(key: 27, name: 'Polyvinyl Chloride'),
  PEBA(key: 28, name: 'Polyether Block Amide'),
  PVDF(key: 29, name: 'Polyvinylidene Fluoride'),
  PPA(key: 30, name: 'Polyphthalamide'),
  PCL(key: 31, name: 'Polycaprolactone'),
  PES(key: 32, name: 'Polyethersulfone'),
  PMMA(key: 33, name: 'Polymethyl Methacrylate'),
  POM(key: 34, name: 'Polyoxymethylene'),
  PPE(key: 35, name: 'Polyphenylene Ether'),
  PS(key: 36, name: 'Polystyrene'),
  PSU(key: 37, name: 'Polysulfone'),
  TPI(key: 38, name: 'Thermoplastic Polyimide'),
  SBS(key: 39, name: 'Styrene-Butadiene-Styrene'),
  OBC(key: 40, name: 'Olefin Block Copolymer'),
  EVA(key: 41, name: 'Ethylene Vinyl Acetate');

  final int key;
  final String name;

  const MaterialTypeEnum({required this.key, required this.name});

  static MaterialTypeEnum byKey(int key) =>
      values.firstWhere((e) => e.key == key);
}
