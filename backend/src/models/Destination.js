class Destination {
  constructor({
    id,
    name,
    country,
    subtitle,
    description,
    icon = 'landscape',
    isPopular = false,
    createdAt,
    updatedAt,
  }) {
    this.id = id;
    this.name = name;
    this.country = country;
    this.subtitle = subtitle;
    this.description = description;
    this.icon = icon;
    this.isPopular = Boolean(isPopular);
    this.createdAt = createdAt || new Date().toISOString();
    this.updatedAt = updatedAt || new Date().toISOString();
  }

  toJSON() {
    return {
      id: this.id,
      name: this.name,
      country: this.country,
      subtitle: this.subtitle,
      description: this.description,
      icon: this.icon,
      isPopular: this.isPopular,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
    };
  }
}

module.exports = Destination;
