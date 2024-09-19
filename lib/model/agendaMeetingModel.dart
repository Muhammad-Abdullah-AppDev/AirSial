class AgendaMeetimgModel {
  int? tid;
  String? tdate;
  String? mtime;
  String? refno;
  String? meeting;
  String? committe;
  String? rmks;
  String? fkmeeting;
  String? mdate;
  String? venue;
  String? fkcmt;
  String? zM_LINK;
  //String? detail;

  AgendaMeetimgModel(
      {this.tid,
      this.tdate,
      this.mtime,
      this.refno,
      this.meeting,
      this.committe,
      this.rmks,
      this.fkmeeting,
      this.mdate,
      this.venue,
      this.fkcmt,
      this.zM_LINK,
      //this.detail
      });

  AgendaMeetimgModel.fromJson(Map<String, dynamic> json) {
    tid = json['TID'];
    tdate = json['TDATE'];
    mtime = json['MTIME'];
    refno = json['REFNO'];
    meeting = json['MEETING'];
    committe = json['COMMITTE'];
    rmks = json['RMKS'];
    fkmeeting = json['FKMEETING'];
    mdate = json['MDATE'];
    venue = json['VENUE'];
    fkcmt = json['FKCMT'];
    zM_LINK = json['ZM_LINK'];
    // detail = json['detail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TID'] = this.tid;
    data['TDATE'] = this.tdate;
    data['MTIME'] = this.mtime;
    data['REFNO'] = this.refno;
    data['MEETING'] = this.meeting;
    data['COMMITTE'] = this.committe;
    data['RMKS'] = this.rmks;
    data['FKMEETING'] = this.fkmeeting;
    data['MDATE'] = this.mdate;
    data['VENUE'] = this.venue;
    data['FKCMT'] = this.fkcmt;
    data['ZM_LINK'] = this.zM_LINK;
    //data['detail'] = this.detail;
    return data;
  }
}
