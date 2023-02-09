# Python dependencies
FROM python:3.9-slim AS build-env
COPY requirements.txt /requirements.txt
RUN pip install --disable-pip-version-check -r /requirements.txt --target /packages

# Final image
FROM gcr.io/distroless/python3

# Add wget for the healtcheck
COPY --from=busybox /bin/wget /usr/bin/wget

# Copy all dependencies
COPY --from=build-env /packages /packages

# Copy main app
COPY app.py persistence_helper.py date_helper.py /app/

# Rootless
USER nobody
ENV PYTHONPATH=/packages

WORKDIR /app

ENV PYTHONPATH=/packages
ENV RV_ECS_APP_DYNDB_TABLE=revolut-interview
ENV RV_ECS_APP_FORCE_LOCAL_MODE=False
CMD ["/packages/bin/gunicorn", "--bind", "0.0.0.0:8000", "app:app"]
HEALTHCHECK  --start-period=15s --interval=1m --timeout=3s  CMD [ "/usr/bin/wget", "--quiet", "--tries=1", "--spider", "http://127.0.0.1:8000/health"]