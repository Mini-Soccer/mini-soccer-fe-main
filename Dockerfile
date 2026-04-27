# stage 1: build the next.js application
FROM node:22.10.0-alpine AS builder

# set the working directory inside the container
WORKDIR /app

# copy the rest of your application code
COPY . .

# install dependencies
RUN npm install

# build the next.js application
RUN npm run build

# stage 2: create the production image
FROM node:22.10.0-alpine

# set the working directory inside the container
WORKDIR /app

# create user and group for application
RUN addgroup -g 1001 nodejs
RUN adduser -D -u 1001 -G nodejs nextjs

# set the correct permission for .next folder
RUN mkdir .next
RUN chown nextjs:nodejs .next

# automatically leverage output traces to reduce image size
# https://nextjs.org/docs/advanced-features/output-file-tracing
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
COPY --from=builder --chown=nextjs:nodejs /app/public ./public


# Switch to the nextjs user
USER nextjs

# Required environment variables
ENV NODE_ENV=production

# set app port
ENV PORT=3000

# set hostname to localhost
ENV HOSTNAME=0.0.0.0

# expose port
EXPOSE 3000

# server.js is created by next build from the standalone output
# di next.js standalone saat run npm run build next.js otomatis bikin => .next/standalone/server.js
CMD ["node", "server.js"]
