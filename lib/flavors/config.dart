enum Config {
  dev,
  qa,
  test,
  prod;

  static Config fromString({required String flavor}) {
    switch (flavor) {
      case "prod":
        return Config.prod;
      case "qa":
        return Config.qa;
      case "test":
        return Config.test;
      case "dev":
      default:
        return Config.dev;
    }
  }
}
