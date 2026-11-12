const bcrypt = require('bcryptjs');
const { generateToken } = require('../utils/token.util');

class AuthService {
  constructor(userRepository) {
    this.userRepo = userRepository;
  }

  async register({ name, email, password }) {
    const existing = await this.userRepo.findByEmail(email.trim());
    if (existing) {
      const error = new Error('An account with this email already exists.');
      error.statusCode = 409;
      throw error;
    }

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    const newUser = await this.userRepo.create({
      name: name.trim(),
      email: email.trim().toLowerCase(),
      passwordHash,
      role: 'traveler',
    });

    const token = generateToken({
      id: newUser.id,
      email: newUser.email,
      name: newUser.name,
      role: newUser.role,
    });

    return {
      user: newUser.toSafeJSON(),
      token,
    };
  }

  async login({ email, password }) {
    const user = await this.userRepo.findByEmail(email.trim());
    if (!user) {
      const error = new Error('Invalid email or password.');
      error.statusCode = 401;
      throw error;
    }

    const isMatch = await bcrypt.compare(password, user.passwordHash);
    if (!isMatch) {
      const error = new Error('Invalid email or password.');
      error.statusCode = 401;
      throw error;
    }

    const token = generateToken({
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
    });

    return {
      user: user.toSafeJSON(),
      token,
    };
  }

  async getCurrentUser(userId) {
    const user = await this.userRepo.findById(userId);
    if (!user) {
      const error = new Error('User not found.');
      error.statusCode = 404;
      throw error;
    }
    return user.toSafeJSON();
  }
}

module.exports = AuthService;
