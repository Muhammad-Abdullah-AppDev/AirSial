class MomModel {
  int? tid;
  int? fktid;
  String? agenda;
  String? fkmeeting;
  String? meeting;
  String? remarks;
  String? mdate;
  String? mtime;
  String? commite;
  String? venue;
  //String? agendadtl;
  // String? momfotitem;
  // String? momfotdtl;

  MomModel({
    this.tid,
    this.fktid,
    this.agenda,
    this.fkmeeting,
    this.meeting,
    this.remarks,
    this.mdate,
    this.mtime,
    this.commite,
    this.venue,
    //this.agendadtl,
    // this.momfotitem,
    // this.momfotdtl,
  });

  MomModel.fromJson(Map<String, dynamic> json) {
    tid = json['TID'];
    fktid = json['FKTID'];
    agenda = json['AGENDA'];
    fkmeeting = json['FKMEETING'];
    meeting = json['Meeting'];
    remarks = json['REMARKS'];
    mdate = json['MDATE'];
    mtime = json['MTIME'];
    commite = json['COMMITE'];
    venue = json['VENUE'];
    //agendadtl = json['AGENDA'];
    // momfotitem = json['momfotitem'];
    // momfotdtl = json['momfotdtl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TID'] = this.tid;
    data['FKTID'] = this.fktid;
    data['AGENDA'] = this.agenda;
    data['FKMEETING'] = this.fkmeeting;
    data['Meeting'] = this.meeting;
    data['REMARKS'] = this.remarks;
    data['MDATE'] = this.mdate;
    data['MTIME'] = this.mtime;
    data['COMMITE'] = this.commite;
    data['VENUE'] = this.venue;
    //data['agendadtl'] = this.agendadtl;
    // data['momfotitem'] = this.momfotitem;
    // data['momfotdtl'] = this.momfotdtl;
    return data;
  }
}
