class NewsModel {
  final int? tRNO;
  final String? tITILE;
  final String? mSG;
  final String? vDT;
  final dynamic nTYPE;

  NewsModel({
    this.tRNO,
    this.tITILE,
    this.mSG,
    this.vDT,
    this.nTYPE,
  });

  NewsModel.fromJson(Map<String, dynamic> json)
      : tRNO = json['TRNO'] as int?,
        tITILE = json['TITILE'] as String?,
        mSG = json['MSG'] as String?,
        vDT = json['VDT'] as String?,
        nTYPE = json['NTYPE'];

  Map<String, dynamic> toJson() => {
    'TRNO' : tRNO,
    'TITILE' : tITILE,
    'MSG' : mSG,
    'VDT' : vDT,
    'NTYPE' : nTYPE
  };
}