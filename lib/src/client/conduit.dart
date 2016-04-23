part of phabricator.client;

class ConduitMethodDescriptor {
  final String description;
  final Map<String, String> params;
  final String returns;

  ConduitMethodDescriptor(this.description, this.params, this.returns);
}

