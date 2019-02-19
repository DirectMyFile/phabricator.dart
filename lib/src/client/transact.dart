part of phabricator.client;

abstract class ConduitTransaction<T> {
  String get type;
  T get value;

  Map<String, dynamic> encode() => {
    "type": type,
    "value": value
  };
}

class ConduitAppliedTransaction<T> extends ConduitTransaction<T> {
  final String type;
  final T value;
  final String phid;

  ConduitAppliedTransaction(this.type, this.value, this.phid);
}

class ConduitEditResult extends ConduitObject<Map<String, dynamic>> {
  List<ConduitAppliedTransaction> transactions;

  @override
  void decode(Map<String, dynamic> input) {
    json = input;

    if (input["object"] is Map) {
      var objectInfo = input["object"];

      phid = objectInfo["phid"];
      id = objectInfo["id"];
    }

    if (input["transactions"] is List) {
      transactions = input["transactions"].map((m) {
        return new ConduitAppliedTransaction(
          m["type"],
          m["value"],
          m["phid"]
        );
      }).toList();
    }
  }
}

abstract class EditableConduitService<T extends ConduitObject>
    extends SearchableConduitService<T> {
  EditableConduitService(ConduitClient client, String type) : super(client, type);

  Future<ConduitEditResult> edit(String id, List<ConduitTransaction> transactions) async {
    var rid = null;
    
    try {
      rid = int.parse(id);
    } on FormatException {}

    if (rid == null) {
      rid = id;
    }

    var result = await callMethod("edit", {
      "objectIdentifier": rid,
      "transactions": transactions
          .map((transaction) => transaction.encode())
          .toList()
    });

    return new ConduitEditResult()..decode(result);
  }

  Future<ConduitEditResult> create(List<ConduitTransaction> transactions) async {
    var result = await callMethod("edit", {
      "objectIdentifier": null,
      "transactions": transactions
          .map((transaction) => transaction.encode())
          .toList()
    });

    return new ConduitEditResult()..decode(result);
  }
}

class NameTransaction extends ConduitTransaction<String> {
  final String value;

  NameTransaction(this.value);


  @override
  String get type => "name";
}
