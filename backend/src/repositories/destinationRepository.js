const Destination = require('../models/Destination');

class DestinationRepository {
  constructor(storageAdapter) {
    this.storage = storageAdapter;
    this.collection = 'destinations';
  }

  async findById(id) {
    const raw = await this.storage.findById(this.collection, id);
    return raw ? new Destination(raw) : null;
  }

  async findAll(filter = {}) {
    let items = await this.storage.read(this.collection);

    if (filter.popular !== undefined) {
      items = items.filter((d) => Boolean(d.isPopular) === Boolean(filter.popular));
    }

    if (filter.search) {
      const q = filter.search.toLowerCase();
      items = items.filter(
        (d) =>
          d.name?.toLowerCase().includes(q) ||
          d.country?.toLowerCase().includes(q) ||
          d.subtitle?.toLowerCase().includes(q) ||
          d.description?.toLowerCase().includes(q)
      );
    }

    return items.map((d) => new Destination(d));
  }

  async create(destinationData) {
    const created = await this.storage.insert(this.collection, destinationData);
    return new Destination(created);
  }

  async update(id, updates) {
    const updated = await this.storage.update(this.collection, id, updates);
    return updated ? new Destination(updated) : null;
  }

  async delete(id) {
    return this.storage.delete(this.collection, id);
  }
}

module.exports = DestinationRepository;
