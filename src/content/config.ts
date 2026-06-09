import { defineCollection, z } from 'astro:content';

const now = defineCollection({
  type: 'content',
  schema: z.object({
    updated: z.date(),
    oneliner: z.string(),
  }),
});

const articles = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    description: z.string(),
    date: z.coerce.date(),
    // SOUL.md: technical articles surface on /writing; non-technical go to /archive.
    technical: z.boolean(),
  }),
});

export const collections = { now, articles };
