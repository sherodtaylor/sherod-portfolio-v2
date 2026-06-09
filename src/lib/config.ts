// Load config.yaml at build time. Same source-of-truth file the PDF resume
// generator (generate-resume.py) consumes — one content source, two surfaces.
// See SOUL.md "Shared resume source".

import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import yaml from 'js-yaml';

const here = dirname(fileURLToPath(import.meta.url));
const configPath = join(here, '..', '..', 'config.yaml');

export interface Contact {
  email: string;
  website: string;
  github: string;
  linkedin: string;
}

export interface Personal {
  name: string;
  title: string;
  location: string;
  description: string;
  // Multi-paragraph About for the website. Optional — falls back to
  // splitting `description` if absent. PDF resume always uses `description`.
  about?: string[];
}

export interface ExperiencePosition {
  company: string;
  company_url?: string;
  role: string;
  period: string;
  location: string;
  description: string;
  achievements?: string[];
  technologies?: string[];
}

export interface ProjectLink {
  href: string;
  label: string;
}

export interface ProjectItem {
  name: string;
  description: string;
  highlights?: string[];
  link: ProjectLink;
  website?: ProjectLink;
  tags?: string[];
}

export interface SkillCategory {
  title: string;
  skills: { name: string }[];
}

export interface PortfolioConfig {
  personal: Personal;
  contact: Contact;
  experience: { positions: ExperiencePosition[] };
  projects: { items: ProjectItem[] };
  skills: { categories: SkillCategory[] };
}

let cached: PortfolioConfig | null = null;

export function loadConfig(): PortfolioConfig {
  if (cached) return cached;
  const text = readFileSync(configPath, 'utf8');
  cached = yaml.load(text) as PortfolioConfig;
  return cached;
}
