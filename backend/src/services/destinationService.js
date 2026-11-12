class DestinationService {
  constructor(destinationRepository) {
    this.destinationRepo = destinationRepository;
  }

  async getAll(filter = {}) {
    const list = await this.destinationRepo.findAll(filter);
    return list.map((d) => d.toJSON());
  }

  async getPopular() {
    const list = await this.destinationRepo.findAll({ popular: true });
    return list.map((d) => d.toJSON());
  }

  async getById(id) {
    const item = await this.destinationRepo.findById(id);
    if (!item) {
      const error = new Error(`Destination with id '${id}' was not found.`);
      error.statusCode = 404;
      throw error;
    }
    return item.toJSON();
  }

  async create(data) {
    const created = await this.destinationRepo.create({
      name: data.name.trim(),
      country: data.country.trim(),
      subtitle: data.subtitle.trim(),
      description: data.description.trim(),
      icon: data.icon || 'landscape',
      isPopular: Boolean(data.isPopular),
    });
    return created.toJSON();
  }

  async update(id, updates) {
    const updated = await this.destinationRepo.update(id, updates);
    if (!updated) {
      const error = new Error(`Destination with id '${id}' was not found.`);
      error.statusCode = 404;
      throw error;
    }
    return updated.toJSON();
  }

  async delete(id) {
    const deleted = await this.destinationRepo.delete(id);
    if (!deleted) {
      const error = new Error(`Destination with id '${id}' was not found.`);
      error.statusCode = 404;
      throw error;
    }
    return true;
  }
}

module.exports = DestinationService;
