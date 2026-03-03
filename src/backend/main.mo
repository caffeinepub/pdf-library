import Text "mo:core/Text";
import Int "mo:core/Int";
import Array "mo:core/Array";
import Map "mo:core/Map";
import Time "mo:core/Time";
import MixinStorage "blob-storage/Mixin";
import Storage "blob-storage/Storage";
import Runtime "mo:core/Runtime";

actor {
  include MixinStorage();

  let pdfEntries = Map.empty<Text, PdfEntry>();
  let adminToken = "dxnamaaz90";

  type PdfEntry = {
    id : Text;
    title : Text;
    description : Text;
    uploadedAt : Int;
    blobId : Text;
  };

  func validateToken(token : Text) {
    if (token != adminToken) {
      Runtime.trap("Invalid admin token");
    };
  };

  public shared ({ caller }) func addPdf(token : Text, title : Text, description : Text, blobId : Text) : async Text {
    validateToken(token);

    let id = title # "-" # Time.now().toText();
    let entry : PdfEntry = {
      id;
      title;
      description;
      uploadedAt = Time.now();
      blobId;
    };

    pdfEntries.add(id, entry);
    id;
  };

  public shared ({ caller }) func deletePdf(token : Text, id : Text) : async () {
    validateToken(token);
    switch (pdfEntries.get(id)) {
      case (null) { Runtime.trap("PDF not found") };
      case (_) {
        pdfEntries.remove(id);
      };
    };
  };

  public query ({ caller }) func listPdfs() : async [PdfEntry] {
    pdfEntries.values().toArray();
  };

  public query ({ caller }) func getPdf(id : Text) : async PdfEntry {
    switch (pdfEntries.get(id)) {
      case (null) { Runtime.trap("PDF not found") };
      case (?entry) { entry };
    };
  };
};
